#!/bin/bash

# Handle Ad Responses Module
# This module provides functions for fetching and processing ad responses from bidder endpoints

# Ensure we're being sourced properly
if [[ -z "$ad_response_generator_context" ]]; then
    echo "ERROR: Cannot invoke handle_ad_responses.sh outside ad_response_generator context"
    echo "Run 'bash ad_response_generator <args>'"
    exit 1
fi

# Configuration Constants
readonly NETWORK_TIMEOUT=2
readonly MAX_RETRIES=2
readonly RETRY_DELAY=1
readonly EMPTY_CHARACTERS_RESPONSE_THRESHOLD=3
readonly PROD_IP_HEADER="216.160.83.56"
readonly PSID_LENGTH=32

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Generate secure PSID with error handling and fallback
generate_secure_psid() {
    local psid
    local fallback_psid

    # Try to generate from /dev/urandom
    if psid=$(tr -dc a-z0-9 </dev/urandom 2>/dev/null | head -c $PSID_LENGTH); then
        if [[ ${#psid} -eq $PSID_LENGTH ]]; then
            echo "$psid"
            return 0
        fi
    fi

    # Fallback: use timestamp and process ID
    fallback_psid="$(date +%s)_$$_$(hostname | head -c 8)"
    fallback_psid=$(echo "$fallback_psid" | tr -dc a-z0-9 | head -c $PSID_LENGTH)

    print_warning "Failed to generate PSID from /dev/urandom, using fallback method"
    echo "$fallback_psid"
}

# Make HTTP request with retry logic and error checking
make_http_request_with_retry() {
    local url="$1"
    local output_file="$2"
    local headers="$3"
    local retry_count=0
    local curl_cmd="curl -s --connect-timeout $NETWORK_TIMEOUT --max-time $NETWORK_TIMEOUT"

    # Add headers if provided
    if [[ -n "$headers" ]]; then
        curl_cmd="$curl_cmd $headers"
    fi

# $(cat "$creative_prod_ad_response_formatted" 2>/dev/null | wc -c) -le $EMPTY_CHARACTERS_RESPONSE_THRESHOLD

    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        if $curl_cmd "$url" 2>/dev/null 1> "$output_file"; then
            # Check if we got a response (not empty)
            if [[ $(cat "$output_file" 2>/dev/null | wc -c) -le $EMPTY_CHARACTERS_RESPONSE_THRESHOLD ]]; then
                print_debug "Empty response from $url (attempt $((retry_count + 1))/$MAX_RETRIES)"
            else
                return 0
            fi
        fi

        retry_count=$((retry_count + 1))
        if [[ $retry_count -lt $MAX_RETRIES ]]; then
            sleep $((RETRY_DELAY * retry_count))
        fi

        # For production request we need to change PSID of TV otherwise bidder will not respond
        if [[ $url == *"$BIDDER_HOST_PROD"* ]]; then
            tv_psid_prod=$(generate_secure_psid)
            url=$(echo $url | sed -r -e "s|psid=[a-z0-9]{${PSID_LENGTH}}|psid=${tv_psid_prod}|")
        fi
    done
    return 1
}

# Validate and format JSON using jq with error handling
validate_and_format_json() {
    local input_file="$1"
    local output_file="$2"

    # Check if input file exists and is not empty
    if [[ ! -f "$input_file" ]] || [[ ! -s "$input_file" ]]; then
        print_error "Input file $input_file is empty or does not exist"
        return 1
    fi

    # Try to format with jq
    if jq --indent 2 . "$input_file" 2>/dev/null 1> "$output_file"; then
        # Verify the formatted file is valid
        if [[ -s "$output_file" ]]; then
            return 0
        else
            print_error "jq produced empty output for $input_file"
            return 1
        fi
    else
        print_warning "Failed to parse JSON from $input_file, copying original"
        # Copy original file as fallback
        cp "$input_file" "$output_file"
        return 1
    fi
}

# Setup and validate output paths
setup_output_paths() {
    local creative_id="$1"
    local index="$2"

    # Ensure output directories exist
    mkdir -p "$output_ad_requests" "$output_ad_responses"

    # Generate file paths
    local creative_ad_request="${output_ad_requests}/${creative_id}.txt"
    local creative_ad_response_original="${output_ad_responses}/${creative_id}_original.json"
    local creative_ad_response_formatted="${output_ad_responses}/${creative_id}_formatted.json"
    local creative_prod_ad_request="${output_ad_requests}/${creative_id}_prod.txt"
    local creative_prod_ad_response_original="${output_ad_responses}/${creative_id}_original_prod.json"
    local creative_prod_ad_response_formatted="${output_ad_responses}/${creative_id}_formatted_prod.json"

    # Return paths as space-separated string
    echo "$creative_ad_request $creative_ad_response_original $creative_ad_response_formatted $creative_prod_ad_request $creative_prod_ad_response_original $creative_prod_ad_response_formatted"
}

# =============================================================================
# CORE FUNCTIONS
# =============================================================================

# Fetch ad response for a single endpoint
fetch_single_ad_response() {
    local endpoint="$1"
    local output_original="$2"
    local output_formatted="$3"
    local request_log="$4"
    local headers="$5"

    # Log the request
    echo "curl -s '$endpoint' $headers" > "$request_log"

    # Make HTTP request with retry
    if make_http_request_with_retry "$endpoint" "$output_original" "$headers"; then
        if validate_and_format_json "$output_original" "$output_formatted"; then
            return 0
        else
            print_warning "JSON validation failed for $endpoint"
            return 1
        fi
    else
        print_debug "Failed to fetch response from $endpoint"
        return 1
    fi
}

# Process responses for a single creative
process_creative_responses() {
    local creative_id="$1"
    local index="$2"
    local creative_pid="${CREATIVES_PIDS[index]}"
    local tv_psid="${TVS_PSIDS[index]}"
    local tv_psid_prod

    # Generate production PSID with error handling
    tv_psid_prod=$(generate_secure_psid)
    if [[ $? -ne 0 ]]; then
        print_error "Failed to generate production PSID for creative $creative_id"
        return 1
    fi

    # Setup output paths
    local paths=($(setup_output_paths "$creative_id" "$index"))
    local creative_ad_request="${paths[0]}"
    local creative_ad_response_original="${paths[1]}"
    local creative_ad_response_formatted="${paths[2]}"
    local creative_prod_ad_request="${paths[3]}"
    local creative_prod_ad_response_original="${paths[4]}"
    local creative_prod_ad_response_formatted="${paths[5]}"

    # Build endpoints
    local endpoint_base="/impressions/tile?pid=${creative_pid}&lang=${TV_LANGUAGE}&co=${TV_COUNTRY}&Modelcode=23_PONTUSM_QTV_8k&Firmcode=T-INFOLINK2023-1013&Adagentver=23.3.1403&Firmver=T-HKMAKUC-1540.3"
    local endpoint_local="${BIDDER_HOST_LOCAL}${endpoint_base}&psid=${tv_psid}"
    local endpoint_prod="${BIDDER_HOST_PROD}${endpoint_base}&psid=${tv_psid_prod}"

    # Fetch local ad response and check if empty
    fetch_single_ad_response "$endpoint_local" "$creative_ad_response_original" "$creative_ad_response_formatted" "$creative_ad_request"
    if [[ $(cat "$creative_ad_response_formatted" 2>/dev/null | wc -c) -le $EMPTY_CHARACTERS_RESPONSE_THRESHOLD ]]; then
        print_warning "Empty 'local' ad response for $creative_id!"
    fi

    # Fetch production ad response  and check if empty
    fetch_single_ad_response "$endpoint_prod" "$creative_prod_ad_response_original" "$creative_prod_ad_response_formatted" "$creative_prod_ad_request" "--header 'x-real-ip: $PROD_IP_HEADER'"
    if [[ $(cat "$creative_prod_ad_response_formatted" 2>/dev/null | wc -c) -le $EMPTY_CHARACTERS_RESPONSE_THRESHOLD ]]; then
        print_warning "Empty 'prod' ad response for $creative_id!"
    fi

    # Update global arrays
    CREATIVES_AD_RESPONSES+=("$creative_ad_response_original")
    CREATIVES_AD_RESPONSES_FORMATTED+=("$creative_ad_response_formatted")
    CREATIVES_PROD_AD_RESPONSES_FORMATTED+=("$creative_prod_ad_response_formatted")
    CREATIVES_AD_REQUESTS+=("$creative_ad_request")
    CREATIVES_PROD_AD_REQUESTS+=("$creative_prod_ad_request")
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

# Main function to get ad responses for multiple creatives
get_ad_responses() {
    local creative_ids=("$@")
    local index=0

    for creative_id in "${creative_ids[@]}"; do
        process_creative_responses "$creative_id" "$index"
        index=$((index + 1))
    done
}
