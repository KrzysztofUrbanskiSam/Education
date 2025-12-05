#!/bin/bash

# TODO:
# - when user provides creatives right now they have to be in order if they are not output is not correct

export ad_response_generator_context="true"

start=`date +%s.%3N`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_DIR=$(git rev-parse --show-toplevel)
source ${SCRIPT_DIR}/utils/print_helper.sh
source ${SCRIPT_DIR}/utils/config.sh
source ${SCRIPT_DIR}/utils/verification.sh
source ${SCRIPT_DIR}/utils/argument_parser.sh
source ${SCRIPT_DIR}/utils/repository_helper.sh
source ${SCRIPT_DIR}/utils/handle_trader.sh
source ${SCRIPT_DIR}/utils/handle_bidder.sh
source ${SCRIPT_DIR}/utils/handle_data_activation.sh
source ${SCRIPT_DIR}/utils/handle_test_tvs.sh
source ${SCRIPT_DIR}/utils/waiters.sh
source ${SCRIPT_DIR}/utils/handle_ad_responses.sh

# function handle_trap() {
#     echo "handling trap"
# }

# trap handle_trap EXIT


function handle_exit() {
    print_info "Handling exit"
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
        print_info "Script invoked with '--no-undo-changes' - will not revert changes in repositories"
    fi

    $DEBUG && echo "DEBUG: Stopping bidder ..."
    bidder_pid=$(ss -lpt | grep 8085 | grep -oP 'pid=\K\d+')
    if [[ -z $bidder_pid ]]; then
        print_error "Bidder process not found by ss command. Trying with ps -aux."
        bidder_pid=$(ps -aux | grep -E "go run.*${ROOT_BIDDER_CONFIG_LOCAL}" | cut -f 2 -d ' ' | xargs | cut -f 1 -d ' ')
    fi
    if [[ -n $bidder_pid ]]; then
        kill -9 $bidder_pid
    else
        print_error "Could not kill bidder process"
    fi
}


parse_arguments "$@"
set_config_from_arguments
do_startup_verification
if [ ! $startup_verification_success == true ]; then
    print_critical "Please correct missing setup and rerun the script"
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
    print_info "Finished setuping repositories. Exiting"
    exit 0
fi

run_bidder &
verify_bidder_works

get_ad_responses ${CREATIVES_IDS[@]}

handle_exit
print_summary
exit 0
