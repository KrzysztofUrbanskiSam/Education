# Colors
if [[ -z "$ad_response_generator_context" ]]; then
    echo "Cannot invoke outside 'ad_response_generator"
    echo "Run 'bash ad_response_generator <args>'"
    exit 1
fi

COLOR_RESET="\033[0m"   # reset
COLOR_RED="\033[31m"    # foreground red
COLOR_GREEN="\033[32m"  # foreground green
COLOR_YELLOW="\033[33m" # foreground yellow
COLOR_BLUE="\033[34m"   # foreground yellow

function print_debug() {
    ${DEBUG} && echo -e "DEBUG: $1"
}

function print_info() {
    echo -e "INFO: $1"
}

function print_info_color() {
    echo -e "${COLOR_BLUE}INFO: $1${COLOR_RESET}"
}

function print_warning() {
    echo -e "${COLOR_YELLOW}WARNING: $1${COLOR_RESET}"
}

function print_error() {
    echo -e "${COLOR_RED}ERROR: $1${COLOR_RESET}"
}

function print_critical() {
    echo -e "${COLOR_RED}CRITICAL: $1${COLOR_RESET}"
    exit 1
}

# =============================================================================

function add_empty_mark() { # $1 = file
    local file="$1"
    if [ ! -e $file ]; then
        echo " ${COLOR_RED}${NOT_EXISTS_MARK}${COLOR_RESET}"
        return
    fi
    if [[ $(wc -c < "$file") -le 3 ]]; then
        echo " ${COLOR_RED}${EMPTY_MARK}${COLOR_RESET}"
    else
        echo ""
    fi
}

function print_summary() {
    print_info_color "Printing summary"
    local index=0
    local summary_file="${OUTPUT}/summary.json"
    local json_output="{}"
    for creative_id in ${CREATIVES_IDS[@]}; do
        EMPTY_MARK_AD_RESPONSE=$(add_empty_mark ${CREATIVES_AD_RESPONSES_FORMATTED[$index]})
        EMPTY_MARK_AD_RESPONSE_PROD=$(add_empty_mark "${CREATIVES_PROD_AD_RESPONSES_FORMATTED[$index]}")

        print_info_color "Summary for ${creative_id} - '${CREATIVES_NAMES[$index]}'"
        print_info "\tParquet file:               ${COLOR_GREEN}${CREATIVES_PARQUETS[$index]}${COLOR_RESET}"
        $DEBUG && print_info "\tBert file:                  ${CREATIVES_BERT[$index]}"
        print_info "\tTerm file:                  ${CREATIVES_TERM[$index]}"
        print_info "\tAd request:                 ${CREATIVES_AD_REQUESTS[$index]}"
        print_info "\tAd request:  (prod example) ${CREATIVES_PROD_AD_REQUESTS[$index]}"
        print_info "\tAd response:                ${COLOR_GREEN}${CREATIVES_AD_RESPONSES_FORMATTED[$index]}${COLOR_RESET}${EMPTY_MARK_AD_RESPONSE}"
        print_info "\tAd response: (prod example) ${CREATIVES_PROD_AD_RESPONSES_FORMATTED[$index]}${EMPTY_MARK_AD_RESPONSE_PROD}"

        json_output=$(echo "$json_output" | jq \
            --arg cid "$creative_id" \
            --arg c_parquet "${CREATIVES_PARQUETS[$index]%$EMPTY_MARK}" \
            --arg ad_req "${CREATIVES_AD_REQUESTS[$index]%$EMPTY_MARK}" \
            --arg ad_resp "${CREATIVES_AD_RESPONSES_FORMATTED[$index]}" \
            --arg c_term "${CREATIVES_TERM[$index]%$EMPTY_MARK}" \
            --arg c_bert "${CREATIVES_BERT[$index]%$EMPTY_MARK}" \
            '. + {($cid): {"ad_request_file": $ad_req,
                           "ad_response_file": $ad_resp,
                           "parquet_file": $c_parquet,
                           "term_file": $c_term,
                           "bert_file": $c_bert}}')

        # Save JSON output to file
        echo "$json_output" | jq --indent 2 . > ${summary_file}
        index=$(expr $index + 1)
    done

    print_info "JSON summary saved to ${COLOR_BLUE}${summary_file}${COLOR_RESET}"
    end=`date +%s.%3N`
    runtime=$( echo "$end - $start" | bc -l )

    print_info_color "Sript executed in ${runtime}s"
}