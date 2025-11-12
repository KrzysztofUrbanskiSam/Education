#!/bin/bash

function verify_bidder_works() {
    local timeout_seconds=${1:-10}
    local start_time=$(date +%s.%3N)
    local end_time
    local elapsed_time
    local health_check_url="http://localhost:8085/health/statuses"
    local curl_output

    echo "INFO: Waiting for bidder to be healthy (timeout: ${timeout_seconds}s)..."
    while true; do
        curl_output=$(curl -s "${health_check_url}")
        end_time=$(date +%s.%3N)
        elapsed_time=$(echo "$end_time - $start_time" | bc)

        if (( $(echo "$elapsed_time >= $timeout_seconds" | bc -l) )); then
            echo "ERROR: Timeout after waiting for ${elapsed_time} seconds. Bidder did not become healthy."
            exit 1
        fi

        if [ -z "$curl_output" ]; then
            sleep 1
            continue
        else
            echo "INFO: Bidder ready after ${elapsed_time} seconds ..."
            return
        fi
    done
}