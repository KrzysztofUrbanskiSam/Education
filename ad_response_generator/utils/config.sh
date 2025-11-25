#!/bin/bash

# Configuration variables for ad_response_generator

# Debug and feature flags
DEBUG=false
BRANCH_BIDDER=""
BRANCH_DA=""

TV_LANGUAGE="en"
TV_COUNTRY="US"

REFRESH_DA_DATA=true
ONLY_DA=false
ONLY_SETUP_REPOSITORIES=false
UNDO_CHANGES=true
UI_MODE=false

# Database configuration
DB_HOST="localhost"
DB_PORT=5432
DB_USER="adgear"
DB_NAME="rtb-trader-dev"

# Bidder host configuration
BIDDER_HOST_LOCAL="http://localhost:8085"
BIDDER_HOST_PROD="https://tvx-canary.adgrx.com"

# Output directory configuration
OUTPUT="${REPO_DIR}/ad_response_generator/runs/$(date '+%Y-%m-%d/%H%M%S')"
EMPTY_MARK=" - empty"

# Root directories (should be set by environment or repository setup)
ROOT_DATA_ACTIVATION=${ROOT_DATA_ACTIVATION}
ROOT_BIDDER=${ROOT_BIDDER}
ROOT_TRADER=${ROOT_TRADER}

# Python script path
PYTHON_PARQUET_TO_JSON=${SCRIPT_DIR}/extract_parquet_files.py

# Initialize arrays for storing creative and test data
CREATIVES_IDS=()
CREATIVES_PIDS=()
CREATIVES_NAMES=()
CREATIVES_PARQUETS=()
CREATIVES_TERM=()
CREATIVES_BERT=()
CREATIVES_AD_RESPONSES=()
CREATIVES_AD_RESPONSES_FORMATTED=()
CREATIVES_AD_REQUESTS=()
CREATIVES_PROD_AD_RESPONSES=()
CREATIVES_PROD_AD_RESPONSES_FORMATTED=()
CREATIVES_PROD_AD_REQUESTS=()
TVS_PSIDS=()

function set_config_from_arguments(){
    DB_CONNECT="psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"

    OUTPUT=${OUTPUT%%/}
    [ -e $OUTPUT ] && rm -rf ${OUTPUT}
    print_info_color "Output directory: $OUTPUT"

    output_ad_requests=${OUTPUT}/ad_requests
    output_ad_responses=${OUTPUT}/ad_responses
    output_artifacts=${OUTPUT}/artifacts
    output_logs=${OUTPUT}/logs
    output_setup=${OUTPUT}/setup
    output_backup=${OUTPUT}/backup
    mkdir -p $output_ad_requests $output_ad_responses $output_artifacts $output_logs $output_setup $output_backup

    OUTPUT_JSON_CREATIVES=${output_artifacts}/creatives.parquet.json
    OUTPUT_TEST_TVS=${output_artifacts}/test_tvs_creatives.parquet.json
}