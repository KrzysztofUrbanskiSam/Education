#!/bin/bash

function verify_bidder_works() {
    local timeout_seconds=${1:-10}
    local start_time=$(date +%s.%N)
    local end_time
    local elapsed_time
    local health_check_url="http://localhost:8085/health/statuses"
    local jq_filter='to_entries[] | select(.value.IsCritical == true and .value.IsReady == false) | [.key, .value.Error]'
    local curl_output
    local jq_output

    echo "INFO: Waiting for bidder to be healthy (timeout: ${timeout_seconds}s)..."

    # while true; do
        curl_output=$(curl -s "${health_check_url}")
        end_time=$(date +%s.%N)
        elapsed_time=$(echo "$end_time - $start_time" | bc)

        echo "CA ${curl_output}"

        # if (( $(echo "$elapsed_time >= $timeout_seconds" | bc -l) )); then
        #     echo "ERROR: Timeout after waiting for ${elapsed_time} seconds. Service did not become healthy."
        #     exit 1
        # fi

        # if [ -z "$curl_output" ]; then
        #     sleep 1
        #     continue
        # fi

        jq_output=$(echo "$curl_output" | jq "${jq_filter}")
        echo "AAAA ${jq_output}"
        # sleep 2

        # if [ -z "$jq_output" ]; then
        #     echo "INFO: Service is healthy after waiting for ${elapsed_time} seconds."
        #     return 0
        # else
        #     echo "INFO: Service not yet healthy. Critical unready services: ${jq_output}. Elapsed: ${elapsed_time}s. Retrying in 0.5s..."
        #     sleep 2
        # fi
    # done
}
