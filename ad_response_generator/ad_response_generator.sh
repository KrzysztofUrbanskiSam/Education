#!/bin/bash

# TODO:
# print warning/errors functions with colors

start=`date +%s.%3N`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR=$(git rev-parse --show-toplevel)
# source ${REPO_DIR}/utils/print_helper.sh
source ${SCRIPT_DIR}/utils/config.sh
source ${SCRIPT_DIR}/utils/verification.sh
source ${SCRIPT_DIR}/utils/argument_parser.sh
source ${SCRIPT_DIR}/utils/repository_helper.sh
source ${SCRIPT_DIR}/utils/handle_trader.sh
source ${SCRIPT_DIR}/utils/handle_bidder.sh
source ${SCRIPT_DIR}/utils/handle_data_activation.sh
source ${SCRIPT_DIR}/utils/handle_test_tvs.sh
source ${SCRIPT_DIR}/utils/waiters.sh
source ${SCRIPT_DIR}/utils/summary.sh

# function handle_trap() {
#     echo "handling trap"
# }

# trap handle_trap EXIT

function get_ad_responses(){
    local creative_ids=("$@")
    local index=0
    echo "INFO: Getting ad responses ..."
    for creative_id in "${creative_ids[@]}"; do
        local creative_pid=${CREATIVES_PIDS[index]}
        # For production we need to have different PSID. Pord bidder has protection to not
        # serve ad too freqently for same PSID
        local tv_psid=${TVS_PSIDS[index]}
        local tv_psid_prod=$(tr -dc a-z0-9 </dev/urandom | head -c 32; echo)

        local creative_ad_request=${output_ad_requests}/${creative_id}.txt
        local creative_ad_response_original=${output_ad_responses}/${creative_id}_original.json
        local creative_ad_response_formatted=${output_ad_responses}/${creative_id}_formatted.json

        local creative_prod_ad_request=${output_ad_requests}/${creative_id}_prod.txt
        local creative_prod_ad_response_original=${output_ad_responses}/${creative_id}_original_prod.json
        local creative_prod_ad_response_formatted=${output_ad_responses}/${creative_id}_formatted_prod.json

        local endpoint_base="/impressions/tile?pid=${creative_pid}&lang=${TV_LANGUAGE}&co=${TV_COUNTRY}&Modelcode=23_PONTUSM_QTV_8k&Firmcode=T-INFOLINK2023-1013&Adagentver=23.3.1403&Firmver=T-HKMAKUC-1540.3"
        local endpoint_local="${BIDDER_HOST_LOCAL}${endpoint_base}&psid=${tv_psid}"
        local endpoint_prod="${BIDDER_HOST_PROD}${endpoint_base}&psid=${tv_psid_prod}"

        # Ask for local ad
        echo "curl -s '$endpoint_local'" 1> ${creative_ad_request}
        curl -s $endpoint_local 2>/dev/null 1> ${creative_ad_response_original}
        cat ${creative_ad_response_original} | jq --indent 2 . &> ${creative_ad_response_formatted}
        CREATIVES_AD_RESPONSES+=(${creative_ad_response_original})

        # Ask for production ad
        echo "curl -s '$endpoint_prod' --header 'x-real-ip: 216.160.83.56'" 1> ${creative_prod_ad_request}
        curl -s $endpoint_prod --header 'x-real-ip: 216.160.83.56' 2>/dev/null 1> ${creative_prod_ad_response_original}
        cat ${creative_prod_ad_response_original} | jq --indent 2 . &> ${creative_prod_ad_response_formatted}
        CREATIVES_PROD_AD_RESPONSES_FORMATTED+=(${creative_prod_ad_response_formatted})

        if [ $(cat ${creative_ad_response_formatted} | wc -c ) -le 3 ]; then
            echo "WARNING: Empty ad response for ${creative_id}! Check logs for more details"
            CREATIVES_AD_RESPONSES_FORMATTED+=("${creative_ad_response_formatted}${EMPTY_MARK}")
        else
            CREATIVES_AD_RESPONSES_FORMATTED+=("${creative_ad_response_formatted}")
        fi
        CREATIVES_AD_REQUESTS+=("${creative_ad_request}")
        CREATIVES_PROD_AD_REQUESTS+=("${creative_prod_ad_request}")
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
        cp ${_bidder_app_go_orig} ${ROOT_BIDDER_APP_GO}
        cp ${_da_metrix_influx_db} ${ROOT_METRIX_INFLUXDB}
    else
        echo "INFO: Script invoked with '--no-undo-changes' - will not revert changes in repositories"
    fi

    $DEBUG && echo "DEBUG: Stopping bidder ..."
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


parse_arguments "$@"
set_config_from_arguments
do_startup_verification
if [ ! $startup_verification_success == true ]; then
    echo "INFO: Please correct missing setup and rerun the script"
    exit 1
fi

setup_da_branch ${BRANCH_DA}
setup_bidder_branch ${BRANCH_BIDDER}
setup_trader_branch ${BRANCH_TRADER}
print_repository_status "${ROOT_TRADER}" "${ROOT_DATA_ACTIVATION}" "${ROOT_BIDDER}"

setup_test_tvs ${CREATIVES_IDS[@]}
setup_data_activation
setup_bidder

if [[ $REFRESH_DA_DATA == true ]]; then {
    generate_preqa_creatives_data
    generate_test_tv_data
    if [[ "${TV_LANGUAGE}" != 'en' ]]; then
        generate_localization_data
    fi
}
fi

convert_da_parquet_to_json
parse_parquet_files
process_term_bert_files

if [[ $ONLY_DA == true ]]; then
    print_summary
    exit 0
fi

populate_bidder_with_data

if [[ $ONLY_SETUP_REPOSITORIES == true ]]; then
    echo "INFO: Finished setuping repositories. Exiting"
    exit 0
fi

run_bidder &
verify_bidder_works

get_ad_responses ${CREATIVES_IDS[@]}

handle_exit
print_summary
exit 0
