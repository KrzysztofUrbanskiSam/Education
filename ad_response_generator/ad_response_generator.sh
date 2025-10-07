#!/bin/bash

# TODO:
# Modyfikcja plikow z biddera jeszcze nie zrobiona
# print warning/errors functions with colors
# init verifcation function (variables, python configuration, sudo run, weryfikacja czy baz dziala)
# undo modyfikacji
# Mozliwosc widzenia modyfikacji w term plikach
# Add localization parquet
# localhost , port, DB kofigurowalne

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

DEBUG=false
BRANCH_BIDDER="main"
BRANCH_DA="master"
REFRESH_DA_DATA=true
DB_CONNECT="psql -h localhost -p 5432 -U adgear -d rtb-trader-dev"
OUTPUT="/tmp/ad-response-generator/$(date '+%Y-%m-%d')"
OUTPUT_JSON_CREATIVES=${OUTPUT}/creatives.parquet.tmp.json

output_ad_requests=${OUTPUT}/ad_requests
output_ad_responses=${OUTPUT}/ad_responses
output_artifacts=${OUTPUT}/artifacts
output_logs=${OUTPUT}/logs
output_setup=${OUTPUT}/setup

ROOT_SQL_PREQA_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/creatives/preqa_creatives.sql
ROOT_SQL_TEST_TVS_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/test_tvs_creatives/test_tvs_creatives.sql
ROOT_SQL_CREATIVES_STRATEGY=${ROOT_DATA_ACTIVATION}/transformation/creatives/creativesStrategy.go
_da_sql_preqa_creatives=${OUTPUT}/preqa_creatives.sql
_da_sql_preqa_creatives_orig=${OUTPUT}/preqa_creatives.sql.orig
_da_sql_ttc=${OUTPUT}/test_tvs_creatives.sql
_da_sql_ttc_orig=${OUTPUT}/test_tvs_creatives.sql.orig

ROOT_BIDDER_DOCKER_COMPOSE=${ROOT_BIDDER}/docker/bidder/docker-compose.deps.yml
ROOT_BIDDER_CONFIG_LOCAL=${ROOT_BIDDER}/configs/bidder/default-local.yaml
_bidder_docker_compose_orig=${OUTPUT}/docker-compose.deps.yml
_bidder_config_local_orig=${OUTPUT}/default-local.yaml

ROOT_GENERATED_DATA=${ROOT_DATA_ACTIVATION}/data-activation
ROOT_GENERATED_TEST_TV_PARQUET=${ROOT_GENERATED_DATA}/test_tvs_creatives/parquet/test_tvs_creatives.parquet
ROOT_GENERATED_PREQA_CREATIVES_PARQUET=${ROOT_GENERATED_DATA}/preqa_creatives/parquet/preqa_creatives.parquet

PYTHON="/home/k.urbanski/.venv/bin/python"
PYTHON_PARQUET_TO_JSON=${SCRIPT_DIR}/extract_parquet_files.py

# Initialize arrays
CREATIVES_IDS=()
CREATIVES_PIDS=()
TVS_PSIDS=()

function handle_init() {
    local verification_success=true
    if ! command cat $ROOT_DATA_ACTIVATION/.git/config 2>/dev/null | grep data-activation-producer-wrapper.git &>/dev/null ; then
        echo "ERROR: Set 'ROOT_DATA_ACTIVATION' pointing to root of data-activation-producer-wrapper repository"
        echo "INFO: Please pull repo from: https://github.com/adgear/data-activation-producer-wrapper"
        verification_success=false
    fi
    if ! command cat $ROOT_BIDDER/.git/config 2>/dev/null | grep rtb-bidder.git &>/dev/null ; then
        echo "ERROR: Set 'ROOT_BIDDER' pointing to root of rtb-bidder repository"
        echo "INFO: Please pull repo from: https://github.com/adgear/rtb-trader"
        verification_success=false
    fi
    if ! command -v go &> /dev/null; then
        echo "ERROR: go is not installed. Please install go to run this script."
        verification_success=false
    fi

    if ! command -v jq &> /dev/null; then
        echo "ERROR: jq is not installed. Please install jq to run this script."
        verification_success=false
    fi

    if ! command echo $GOPRIVATE | grep "github.com/adgear" &> /dev/null; then
        echo "ERROR: Set GOPRIVATE environment variable to include github.com/adgear"
        echo "INFO: Do this by adding 'export GOPRIVATE=\"github.com/adgear\"' to your ~/.bashrc file"
        verification_success=false
    fi

    if ! command echo $GOPROXY | grep "https://proxy.golang.org" | grep direct &> /dev/null; then
        echo "ERROR: Set GOPROXY environment variable to include 'https://proxy.golang.org' and 'direct'"
        echo "INFO: Do this by adding 'export GOPROXY=\"https://proxy.golang.org,direct\"' to your ~/.bashrc file"
        verification_success=false
    fi

    if [ ! $verification_success == true ]; then
        echo "INFO: Please correct missing setup and rerun the script"
        exit 1
    fi

    if ! command ${PYTHON} -c "import argparse,pyarrow" &> /dev/null; then
        echo "WARNING: Python3 is not correctly configured. Please install argparse and pyarrow"
        echo "INFO: Without Python it is impossible to convert data-activation output to JSON"
    fi

    [ -e $OUTPUT ] && rm -rf ${OUTPUT}
    echo "INFO: Output directory: $OUTPUT"
    mkdir -p $output_ad_requests $output_ad_responses $output_artifacts $output_logs $output_setup
}

function replace_where_clause(){
    sql_file=$1
    where_search=$2
    where_clause=$3

    if grep -q "$where_search" "${sql_file}"; then
        sed -i "s/$where_search.*/$where_clause/" "${sql_file}"
    else
        sed -i -E "s/(.*)((ORDER|GROUP) BY 1)/\1$where_clause\n\1\2/" "${sql_file}"
    fi
}

function setup_data_activation(){
    # Modify preqa_creatives.sql to get affected creatives
    local creative_ids_list=$(IFS=', '; echo "${CREATIVES_IDS[*]}")
    local where_search="WHERE[[:space:]]\+vw_creatives"
    local where_clause="WHERE vw_creatives.id IN ($creative_ids_list)"

    cp ${ROOT_SQL_PREQA_CREATIVES} ${_da_sql_preqa_creatives_orig}
    replace_where_clause "${ROOT_SQL_PREQA_CREATIVES}" "${where_search}" "${where_clause}"
    cp ${ROOT_SQL_PREQA_CREATIVES} ${_da_sql_preqa_creatives}

    local creative_ids_list=$(IFS=', '; echo "${CREATIVES_IDS[*]}")
    local where_search="WHERE[[:space:]]\+creative_id"
    local where_clause="WHERE creative_id IN ($creative_ids_list)"
    cp ${ROOT_SQL_TEST_TVS_CREATIVES} ${_da_sql_ttc_orig}
    replace_where_clause "${ROOT_SQL_TEST_TVS_CREATIVES}" "${where_search}" "${where_clause}"
}

function setup_bidder(){
    cp ${ROOT_BIDDER_DOCKER_COMPOSE} ${_bidder_docker_compose_orig}
    cp ${ROOT_BIDDER_CONFIG_LOCAL} ${_bidder_config_local_orig}

    sed -i -r -E "s|(-.*fake-ups.ym)|# \1|g" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|url:\s*.*unleash.*|url: http://localhost:51000|g" ${ROOT_BIDDER_CONFIG_LOCAL}
    sed -i '/^familyhub:$/ { n; s/true/false/ }' ${ROOT_BIDDER_CONFIG_LOCAL}
}

# Conisder making it as a dictionary
function get_creaitve_pid(){
    if [ "$1" == "Creatives::StvFirstScreenMasthead" ]; then
        echo "2400"
    elif [ "$1" == "Creatives::StvEdenImmersion" ]; then
        echo "9047"
    elif [ "$1" == "Creatives::StvGamerHub" ]; then
        if [ "$2" == "64" ]; then
            echo "2410"
        fi
        if [ "$2" == "71" ]; then
            echo "2420"
        fi
    elif [ "$1" == "Creatives::StvUgPreviewCompanion" ]; then
        echo "9037"
    else
        echo ""
    fi
}

function execute_sql_query() {
    echo "$($DB_CONNECT -t -c "$1" | tr '|' ',')"
}

function parse_arguments() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --creatives-ids)
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                    CREATIVES_IDS+=("$1")
                    shift
                done
                ;;
            --branch-bidder)
                shift
                BRANCH_BIDDER="$1"
                shift
                ;;
            --branch-data-activation)
                shift
                BRANCH_DA="$1"
                shift
                ;;
            --no-da-refresh)
                REFRESH_DA_DATA=false
                shift
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --output)
                shift
                OUTPUT="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: $0 --creatives_ids id1 id2 ... --psids psid1 psid2 ..."
                exit 1
                ;;
        esac
    done
}

function setup_test_tvs() {
    local creative_ids=("$@")
    local creatives_ready=true
    echo "INFO: Setting up test TVs ..."
    for creative_id in "${creative_ids[@]}"; do
        # TODO: Verify creative_id is created at all
        local tv_name="test_tv_for_${creative_id}"
        local tv_data=$(execute_sql_query "SELECT id, psid FROM test_tvs WHERE name='$tv_name';")
        local tv_id=$(echo $tv_data | cut -d',' -f1 | xargs)
        local tv_psid=$(echo $tv_data | cut -d',' -f2 | xargs)

        local creative_data=$(execute_sql_query "SELECT type, creative_subtype_id, life_stage FROM creatives WHERE id='$creative_id';")
        local creative_type=$(echo $creative_data | cut -d',' -f1 | xargs)
        local creative_subtype=$(echo $creative_data | cut -d',' -f2 | xargs)
        local creative_lifestage=$(echo $creative_data | cut -d',' -f3 | xargs)

        if [[ ${creative_lifestage} != "ready" ]]; then
            echo "WARNING: Creative ${creative_id} is not 'ready'."
            creatives_ready=false
            continue
        fi

        # Create Dedicated Test TV
        if [[ -z $tv_id ]]; then
            local tv_psid=$(tr -dc a-z0-9 </dev/urandom | head -c 32; echo)
            $DEBUG && echo "Creating new test TV record for psid: $psid"
            $DB_CONNECT -c "INSERT INTO test_tvs (name, model, country_id, psid, state) VALUES ('$tv_name', '22-25', 238, '$tv_psid', 'active');"
            local tv_data=$(execute_sql_query "SELECT id, psid FROM test_tvs WHERE name='$tv_name';")
            local tv_id=$(echo $tv_data | cut -d',' -f1)
        fi
        # echo $creative_type
        # creative_type="Creatives::StvGamerHub"
        # local creative_pid=${CREATIVE_TYPE_TO_PID_MAP["$creative_type"]}
        local creative_pid=$(get_creaitve_pid $creative_type $creative_subtype)
        if [ -z "${creative_pid}" ]; then
            echo "WARNING: for ${creative_id} cannot find pid"
        fi

        # Assign creative_id with dedicated TV
        local creative_test_tv_id=$(execute_sql_query "SELECT test_tv_id FROM test_tvs_creatives WHERE creative_id='$creative_id' AND test_tv_id='${tv_id}';")
        if [[ -z $creative_test_tv_id ]]; then
            $DB_CONNECT -c "INSERT INTO test_tvs_creatives (creative_id, test_tv_id) VALUES ($creative_id, $tv_id);"
            local creative_test_tv_id=$(execute_sql_query "SELECT test_tv_id FROM test_tvs_creatives WHERE creative_id='$creative_id';" | tr '|' ',' | xargs)
        fi

        CREATIVES_PIDS+=("${creative_pid}")
        TVS_PSIDS+=("$tv_psid")
        echo "INFO: Setup for creative ${creative_id} -> PID:${creative_pid} PSID:${tv_psid}"
    done

    if [[ $creatives_ready != true ]]; then
        echo "INFO: One of provided creative is not ready. Probably needs to be transcoded"
        echo "HINT: To perform transcoding, run rtb-trader and additionally in separate terminal run:"
        echo "HINT: QUEUE=* rails resque:work"
        echo "HINT: Open your creative, save again, refresh preview page, and notice 'green dot' indicating creative is ready"
    fi

    if [[ ${#TVS_PSIDS[@]} == 0 ]]; then
        echo "ERROR: No creatives were set up properly. Exiting... "
        exit 1
    fi
}

function get_test_tvs_creatives(){
    local creative_ids_list=$(IFS=', '; echo "${CREATIVES_IDS[*]}")
    local where_search="WHERE[[:space:]]\+creative_id"
    local where_clause="WHERE creative_id IN ($creative_ids_list)"

    replace_where_clause "${ROOT_SQL_TEST_TVS_CREATIVES}" "${where_search}" "${where_clause}"
}

function generate_test_tv_data(){
    echo "INFO: Generating Test TV data. May take 10s ..."
    rm -f ${ROOT_GENERATED_TEST_TV_PARQUET}
    cd ${ROOT_DATA_ACTIVATION}
    ./dev-run.sh test_tvs_creatives &> /dev/null
    if [ ! -e ${ROOT_GENERATED_TEST_TV_PARQUET} ]; then
        echo "Failed to generate test_tvs_creatives parquet. Exiting ..." && exit 1
    fi
}

function generate_preqa_creatives_data(){
    echo "INFO: Generating preqa creatives data. May take 15s"
    rm -f ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET}
    cd ${ROOT_DATA_ACTIVATION}
    ./dev-run.sh preqa_creatives &> /dev/null
    if [ ! -e ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ]; then
        echo "ERROR: Failed to generate preqa_creatives parquet. Exiting ..." && exit 1
    fi
}

function convert_da_parquet_to_json() {
    ${PYTHON} ${PYTHON_PARQUET_TO_JSON} ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${OUTPUT_JSON_CREATIVES}
}

function parse_parquet_files() {
    while IFS= read -r line; do
        id=$(echo "$line" | jq -r '.Id')
        creative_parquet_out_json=${OUTPUT}/creative_da_json_${id}.json
        echo $line &> ${creative_parquet_out_json}
        echo "INFO: DA json output for creative_id: $id saved to ${creative_parquet_out_json}"

    done < ${OUTPUT_JSON_CREATIVES}

}

function populate_bidder_with_data() {
    echo "INFO: populating bidder with DA data ..."
    cp ${ROOT_GENERATED_TEST_TV_PARQUET} ${ROOT_BIDDER}/test/data-activation/data
    cp ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/preqa_creatives.parquet
    cp ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/creatives.parquet
}

function run_bidder_services(){
    echo "INFO: starting bidder services ..."
    cd ${ROOT_BIDDER}
    make start-local-env &> ${OUTPUT}/logs/bidder_services.txt
}

function run_bidder(){
    echo "INFO: starting bidder ..."
    cd ${ROOT_BIDDER}
    go run ${ROOT_BIDDER}/cmd/bidder/ -configFile ${ROOT_BIDDER_CONFIG_LOCAL} &> ${OUTPUT}/logs/bidder.txt
}

function get_ad_responses(){
    local creative_ids=("$@")
    local index=0
    echo "INFO: Getting ad responses ..."
    for creative_id in "${creative_ids[@]}"; do
        local creative_ad_response=${output_ad_responses}/${creative_id}.json
        local creative_ad_request=${output_ad_requests}/${creative_id}.txt
        local creative_pid=${CREATIVES_PIDS[index]}
        local tv_psid=${TVS_PSIDS[index]}

        local endpoint="http://localhost:8085/impressions/tile?pid=${creative_pid}&lang=en&Modelcode=23_PONTUSM_QTV_8k&psid=${tv_psid}&Firmcode=T-INFOLINK2023-1013&Adagentver=23.3.1403"

        echo "curl -s '$endpoint'" &> ${creative_ad_request}
        curl -s $endpoint | jq --indent 2 . &> ${creative_ad_response}
        echo -e "INFO: For ${creative_id}\n\tAd request: ${creative_ad_request}\n\tAd response: ${creative_ad_response}"
        index=$(expr $index + 1)
    done
}

function handle_exit(){
    echo "INFO: Handling exit"
    cp ${_da_sql_preqa_creatives_orig} ${ROOT_SQL_PREQA_CREATIVES}
    cp ${_da_sql_ttc_orig} ${ROOT_SQL_TEST_TVS_CREATIVES}
    cp ${_bidder_docker_compose_orig} ${ROOT_BIDDER_DOCKER_COMPOSE}
    cp ${_bidder_config_local_orig} ${ROOT_BIDDER_CONFIG_LOCAL}

    echo "INFO: Stopping bidder services ..."
    make stop-local-env &> /dev/null
    echo "INFO: Stopping bidder ..."
    bidder_pid=$(sudo ss -lpt | grep 8085 | grep -oP 'pid=\K\d+')
    echo $bidder_pid
    kill -9 $bidder_pid
}

handle_init
parse_arguments "$@"
setup_test_tvs ${CREATIVES_IDS[@]}
setup_data_activation
setup_bidder

if [[ $REFRESH_DA_DATA == true ]]; then {
    generate_preqa_creatives_data
    generate_test_tv_data
}
fi

# convert_da_parquet_to_json
parse_parquet_files

populate_bidder_with_data

run_bidder_services &
sleep 5s
run_bidder &
sleep 5s

get_ad_responses ${CREATIVES_IDS[@]}

handle_exit

exit 0
