#!/bin/bash

# TODO:
# print warning/errors functions with colors
# Mozliwosc widzenia modyfikacji w term plikach

start=`date +%s.%N`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR=$(git rev-parse --show-toplevel)
# source ${REPO_DIR}/utils/print_helper.sh
source ${SCRIPT_DIR}/utils/verification.sh
source ${SCRIPT_DIR}/utils/argument_parser.sh
source ${SCRIPT_DIR}/utils/repository_setuper.sh
source ${SCRIPT_DIR}/utils/waiters.sh

DEBUG=false
AD_LANGUAGE="en"
BRANCH_BIDDER=""
BRANCH_DA=""
REFRESH_DA_DATA=true
UNDO_CHANGES=true
UI_MODE=false

DB_HOST="localhost"
DB_PORT=5432
DB_USER="adgear"
DB_NAME="rtb-trader-dev"

OUTPUT="${REPO_DIR}/ad_response_generator/runs/$(date '+%Y-%m-%d/%H%M%S')"
EMPTY_MARK=" - empty"

output_ad_requests=${OUTPUT}/ad_requests
output_ad_responses=${OUTPUT}/ad_responses
output_artifacts=${OUTPUT}/artifacts
output_logs=${OUTPUT}/logs
output_setup=${OUTPUT}/setup
output_backup=${OUTPUT}/backup

ROOT_DATA_ACTIVATION=${ROOT_DATA_ACTIVATION}
ROOT_BIDDER=${ROOT_BIDDER}

PYTHON_PARQUET_TO_JSON=${SCRIPT_DIR}/extract_parquet_files.py

# Initialize arrays
CREATIVES_IDS=()
CREATIVES_PIDS=()
CREATIVES_NAMES=()
CREATIVES_PARQUETS=()
CREATIVES_TERM=()
CREATIVES_BERT=()
CREATIVES_AD_RESPONSES=()
CREATIVES_AD_REQUESTS=()
TVS_PSIDS=()

# Conisder making it as a dictionary
function get_creaitve_pid(){
    if [ "$1" == "Creatives::StvFirstScreenMasthead" ]; then
        if [ "$2" == "59" ]; then
            echo "2220"
        else
            echo "2400"
        fi
    elif [ "$1" == "Creatives::StvEdenImmersion" ]; then
        echo "9047"
    elif [ "$1" == "Creatives::StvGamerHub" ]; then
        if [ "$2" == "60" ]; then
            echo "2230"
        fi
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

function setup_test_tvs() {
    local creative_ids=("$@")
    local creatives_ready=true
    echo "INFO: Setting up test TVs ..."
    for creative_id in "${creative_ids[@]}"; do
        local creative_data=$(execute_sql_query "SELECT type, creative_subtype_id, life_stage, name FROM creatives WHERE id='$creative_id';")
        local creative_type=$(echo $creative_data | cut -d',' -f1 | xargs)
        local creative_subtype=$(echo $creative_data | cut -d',' -f2 | xargs)
        local creative_lifestage=$(echo $creative_data | cut -d',' -f3 | xargs)
        local creative_name=$(echo $creative_data | cut -d',' -f4 | xargs)

        if [[ -z "${creative_data}" ]]; then
            echo "ERROR: Creative ${creative_id} does not exist in database. Exiting..."
            exit 1
        fi

        if [[ ${creative_lifestage} != "ready" ]]; then
            echo "WARNING: Creative ${creative_id} is not 'ready'. Ignoring from futher processing"
            creatives_ready=false
            continue
        fi

        local tv_name="test_tv_for_${creative_id}"

        # TODO: Add protection if creative has more then 1 assigned TV (like 'fake' and 'production')
        local tv_data=$(execute_sql_query "SELECT id, psid FROM test_tvs WHERE name='$tv_name';")
        local tv_id=$(echo $tv_data | cut -d',' -f1 | xargs)
        local tv_psid=$(echo $tv_data | cut -d',' -f2 | xargs)

        # Create Dedicated Test TV
        if [[ -z $tv_id ]]; then
            local tv_psid=$(tr -dc a-z0-9 </dev/urandom | head -c 32; echo)
            $DEBUG && echo "Creating new test TV record for psid: $psid"
            $DB_CONNECT -c "INSERT INTO test_tvs (name, model, country_id, psid, state) VALUES ('$tv_name', '22-25', 238, '$tv_psid', 'active');" &> /dev/null
            # $DB_CONNECT -c "INSERT INTO test_tvs (name, model, country_id, psid, state) VALUES ('$tv_name', '22-25', 238, 'i5owir66ktsotl7s2g7yuapxlb4cejcy', 'active');"
            local tv_data=$(execute_sql_query "SELECT id, psid FROM test_tvs WHERE name='$tv_name';")
            local tv_id=$(echo $tv_data | cut -d',' -f1)
        fi
        local creative_pid=$(get_creaitve_pid $creative_type $creative_subtype)
        if [ -z "${creative_pid}" ]; then
            echo "ERROR: for ${creative_id} cannot find pid."
            echo "HINT: Contact script maintainers"
            exit 1
        fi

        # Assign creative_id with dedicated TV
        local creative_test_tv_id=$(execute_sql_query "SELECT test_tv_id FROM test_tvs_creatives WHERE creative_id='$creative_id' AND test_tv_id='${tv_id}';")
        if [[ -z $creative_test_tv_id ]]; then
            $DB_CONNECT -c "INSERT INTO test_tvs_creatives (creative_id, test_tv_id) VALUES ($creative_id, $tv_id);"
            local creative_test_tv_id=$(execute_sql_query "SELECT test_tv_id FROM test_tvs_creatives WHERE creative_id='$creative_id';" | tr '|' ',' | xargs)
        fi

        CREATIVES_PIDS+=("${creative_pid}")
        CREATIVES_NAMES+=("${creative_name}")
        TVS_PSIDS+=("$tv_psid")
        $DEBUG && echo "INFO: Setup for creative ${creative_id} -> PID:${creative_pid} PSID:${tv_psid}"
    done

    if [[ $creatives_ready != true ]]; then
        echo "INFO: One of provided creative is not ready. Probably needs to be transcoded"
        echo "HINT: To perform transcoding, run rtb-trader and additionally in separate terminal run:"
        echo "HINT: QUEUE=* rails resque:work"
        echo "HINT: Open your creative, save again, refresh preview page, and notice 'green dot' indicating creative is ready."
        exit 1
    fi

    if [[ ${#TVS_PSIDS[@]} == 0 ]]; then
        echo "ERROR: Provided creatives were not set up properly. Exiting... "
        exit 1
    fi
}

function generate_test_tv_data(){
    echo "INFO: Generating Test TV data..."
    rm -f ${ROOT_GENERATED_TEST_TV_PARQUET}
    cd ${ROOT_DATA_ACTIVATION}
    ${ROOT_DEV_RUN} test_tvs_creatives &> ${OUTPUT}/logs/data-activation-test_tvs.txt
    if [ ! -e ${ROOT_GENERATED_TEST_TV_PARQUET} ]; then
        echo "Failed to generate test_tvs_creatives parquet. Exiting ..." && exit 1
    fi
    echo "INFO: Generated parquet for test_tvs: ${ROOT_GENERATED_TEST_TV_PARQUET}"
}

function generate_preqa_creatives_data(){
    echo "INFO: Generating preqa creatives data..."
    rm -f ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET}
    cd ${ROOT_DATA_ACTIVATION}
    ${ROOT_DEV_RUN} preqa_creatives &> ${OUTPUT}/logs/data-activation-preqa-creatives.txt
    if [ ! -e ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ]; then
        echo "ERROR: Failed to generate preqa_creatives parquet. Exiting ..." && exit 1
    fi
}

function generate_localization_data(){
    echo "INFO: Generating localization data..."
    cd ${ROOT_DATA_ACTIVATION}
    rm -f ${ROOT_GENERATED_LOCALIZATION_PARQUET}
    ${ROOT_DEV_RUN} localization &> ${OUTPUT}/logs/data-activation-localization.txt
    if [ ! -e ${ROOT_GENERATED_LOCALIZATION_PARQUET} ]; then
        echo "ERROR: Failed to generate localization parquet. Exiting ..." && exit 1
    fi
}

function convert_da_parquet_to_json() {
    ${PYTHON} ${PYTHON_PARQUET_TO_JSON} ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${OUTPUT_JSON_CREATIVES}
    ${PYTHON} ${PYTHON_PARQUET_TO_JSON} ${ROOT_GENERATED_TEST_TV_PARQUET} ${OUTPUT_TEST_TVS}
    echo "INFO: Output in json for preqa_creatives: ${OUTPUT_JSON_CREATIVES}"
    echo "INFO: Output in json for test_tvs_creatives: ${OUTPUT_TEST_TVS}"
}

function process_term_bert_files() {
    echo "INFO: Processing term bert files ..."
    term_files=$(find ${ROOT_GENERATED_DATA_PREQUA_CREATIVES_TERM}/ -type f -name "*.term" | xargs)

    for creative_id in ${CREATIVES_IDS[@]}; do
        local creative_term_file="${output_artifacts}/creative_term_${creative_id}.term"
        local creative_bert_file="${output_artifacts}/creative_term_${creative_id}.bert2"
        touch ${creative_term_file} ${creative_bert_file}
        term_file_found=false
        for term_file in $term_files; do
            if grep -q "$creative_id" "${term_file}"; then
                term_file_found=true
                bert_file=$(dirname ${term_file})/creatives.bert2
                cp ${term_file} ${creative_term_file}
                # echo "INFO: For ${creative_id} generated term file: ${creative_term_file}"
                CREATIVES_TERM+=("${creative_term_file}")

                if [[ -e ${bert_file} ]]; then
                    cp ${bert_file} ${creative_bert_file}
                    CREATIVES_BERT+=("${creative_bert_file}")
                    # echo "INFO: For ${creative_id} generated bert file: ${creative_bert_file}"
                else
                    echo "WARNING: For ${creative_id} cannot find bert file: ${creative_bert_file}"
                    CREATIVES_BERT+=("${creative_bert_file}${EMPTY_MARK}")
                fi
                break
            fi
        done
        if [ "$term_file_found" = false ]; then
            echo "ERROR: No term and bert files found for creative_id $creative_id"
            CREATIVES_BERT+=("${creative_bert_file}${EMPTY_MARK}")
            CREATIVES_TERM+=("${creative_term_file}${EMPTY_MARK}")
        fi
    done
}

# function handle_trap() {
#     echo "handling trap"
# }

# trap handle_trap EXIT

function parse_parquet_files() {
    while IFS= read -r line; do
        id=$(echo "$line" | jq -r '.Id')
        creative_parquet_out_json=${output_artifacts}/creative_da_json_${id}.json
        echo $line &> ${creative_parquet_out_json}
        # echo "INFO: For creative_id: $id parquet file: ${creative_parquet_out_json}"
        CREATIVES_PARQUETS+=("${creative_parquet_out_json}")

    done < ${OUTPUT_JSON_CREATIVES}

}

function populate_bidder_with_data() {
    echo "INFO: populating bidder with DA data ..."
    if [ ! -e ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ]; then
        echo "ERROR: Generated 'preqa_creatives' data not found."
        if [[ $REFRESH_DA_DATA == false ]]; then
            echo "HINT: Rerun script without '--no-da-refresh' flag"
        fi
        exit 1
    fi
    cp ${ROOT_GENERATED_TEST_TV_PARQUET} ${ROOT_BIDDER}/test/data-activation/data
    cp ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/preqa_creatives.parquet
    cp ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/creatives.parquet
    if [ ${AD_LANGUAGE} != "en" ]; then
        if [ ! -e ${ROOT_GENERATED_LOCALIZATION_PARQUET} ]; then
            cp ${ROOT_GENERATED_LOCALIZATION_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/localization.parquet
        else
            echo "WARNING: Localization parquet file not found. Default 'Ad language' will be 'en'"
        fi
    fi
}

function run_bidder_services(){
    echo "INFO: starting bidder services ..."
    cd ${ROOT_BIDDER}
    make stop-fake-unleash &> ${OUTPUT}/logs/bidder_services_stop.txt
    make start-fake-unleash &> ${OUTPUT}/logs/bidder_services_start.txt
    # make stop-local-env &> ${OUTPUT}/logs/bidder_services_stop.txt
    # make start-local-env &> ${OUTPUT}/logs/bidder_services_start.txt
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

        local endpoint="http://localhost:8085/impressions/tile?pid=${creative_pid}&lang=${AD_LANGUAGE}&Modelcode=23_PONTUSM_QTV_8k&psid=${tv_psid}&Firmcode=T-INFOLINK2023-1013&Adagentver=23.3.1403&Firmver=T-HKMAKUC-1540.3"

        echo "curl -s '$endpoint'" &> ${creative_ad_request}
        curl -s $endpoint | jq --indent 2 . &> ${creative_ad_response}
        # echo -e "INFO: For ${creative_id}\n\tAd request: ${creative_ad_request}\n\tAd response: ${creative_ad_response}"
        if [ $(cat ${creative_ad_response} | wc -c ) -le 3 ]; then
            echo "WARNING: Empty ad response for ${creative_id}! Check logs for more details"
            CREATIVES_AD_RESPONSES+=("${creative_ad_response}${EMPTY_MARK}")
        else
            CREATIVES_AD_RESPONSES+=("${creative_ad_response}")
        fi
        CREATIVES_AD_REQUESTS+=("${creative_ad_request}")
        index=$(expr $index + 1)
    done
}

function handle_exit() {
    echo "INFO: Handling exit"
    # TODO: Changes undo should be in repository_setuper
    if [[ $UNDO_CHANGES == true ]]; then
        cp ${_da_dev_run} ${ROOT_DEV_RUN}
        cp ${_da_sql_preqa_creatives_orig} ${ROOT_SQL_PREQA_CREATIVES}
        cp ${_da_sql_ttc_orig} ${ROOT_SQL_TEST_TVS_CREATIVES}
        cp ${_da_sql_creatives_strategy_orig} ${ROOT_SQL_CREATIVES_STRATEGY}
        cp ${_da_test_tvs_creatives} ${ROOT_TEST_TVS_CREATIVES}
        cp ${_bidder_docker_compose_orig} ${ROOT_BIDDER_DOCKER_COMPOSE}
        cp ${_bidder_config_local_orig} ${ROOT_BIDDER_CONFIG_LOCAL}
        cp ${_da_metrix_influx_db} ${ROOT_METRIX_INFLUXDB}
    else
        echo "INFO: Script invoked with '--no-undo-changes' - will not revert changes in repositories"
    fi

    echo "INFO: Stopping bidder services ..."
    make stop-fake-unleash &>/dev/null
    echo "INFO: Stopping bidder ..."
    bidder_pid=$(ss -lpt | grep 8085 | grep -oP 'pid=\K\d+')
    if [[ -z $bidder_pid ]]; then
        echo "ERROR: Bidder process not found by ss command. Trying with ps -aux."
        bidder_pid=$(ps -aux | grep -E "go run.*${ROOT_BIDDER_CONFIG_LOCAL}" | cut -f 2 -d ' ' | xargs | cut -f 1 -d ' ')
    fi
    if [[ -n $bidder_pid ]]; then
        kill -9 $bidder_pid
    else
        echo "ERROR: Could not kill bidder process"
    fi
}


function print_summary() {
    echo "INFO: Printing summary"
    local index=0
    local summary_file="${OUTPUT}/summary.json"
    local json_output="{}"
    for creative_id in ${CREATIVES_IDS[@]}; do
        echo "INFO: Summary for ${creative_id} - '${CREATIVES_NAMES[$index]}'"
        echo -e "INFO:\tParquet file: ${CREATIVES_PARQUETS[$index]}"
        echo -e "INFO:\tBert file:    ${CREATIVES_BERT[$index]}"
        echo -e "INFO:\tTerm file:    ${CREATIVES_TERM[$index]}"
        echo -e "INFO:\tAd request:   ${CREATIVES_AD_REQUESTS[$index]}"
        echo -e "INFO:\tAd response:  ${CREATIVES_AD_RESPONSES[$index]}"

        json_output=$(echo "$json_output" | jq \
            --arg cid "$creative_id" \
            --arg c_parquet "${CREATIVES_PARQUETS[$index]%$EMPTY_MARK}" \
            --arg ad_req "${CREATIVES_AD_REQUESTS[$index]%$EMPTY_MARK}" \
            --arg ad_resp "${CREATIVES_AD_RESPONSES[$index]%$EMPTY_MARK}" \
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

    echo "INFO: JSON summary saved to ${summary_file}"
}

parse_arguments "$@"
DB_CONNECT="psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME}"

do_startup_verification
if [ ! $startup_verification_success == true ]; then
    echo "INFO: Please correct missing setup and rerun the script"
    exit 1
fi

[ -e $OUTPUT ] && rm -rf ${OUTPUT}
echo "INFO: Output directory: $OUTPUT"
mkdir -p $output_ad_requests $output_ad_responses $output_artifacts $output_logs $output_setup $output_backup
OUTPUT_JSON_CREATIVES=${output_artifacts}/creatives.parquet.json
OUTPUT_TEST_TVS=${output_artifacts}/test_tvs_creatives.parquet.json

setup_da_branch ${BRANCH_DA}
setup_bidder_branch ${BRANCH_BIDDER}
print_repository_status "${ROOT_DATA_ACTIVATION}" "${ROOT_BIDDER}"

setup_test_tvs ${CREATIVES_IDS[@]}
setup_data_activation
setup_bidder

if [[ $REFRESH_DA_DATA == true ]]; then {
    generate_preqa_creatives_data
    generate_test_tv_data
    if [[ "${AD_LANGUAGE}" != 'en' ]]; then
        generate_localization_data
    fi
}
fi

convert_da_parquet_to_json
parse_parquet_files
process_term_bert_files

populate_bidder_with_data

run_bidder_services &
sleep 1s
run_bidder &
sleep 1s

# verify_bidder_works

get_ad_responses ${CREATIVES_IDS[@]}

handle_exit
print_summary
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )

echo "INFO: Sript executed in ${runtime}s"
exit 0