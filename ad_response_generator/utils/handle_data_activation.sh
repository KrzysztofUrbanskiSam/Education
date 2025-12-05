if [[ -z "$ad_response_generator_context" ]]; then
    echo "Cannot invoke outside 'ad_response_generator"
    echo "Run 'bash ad_response_generator <args>'"
    exit 1
fi

function setup_da_branch() {
    local repo_branch="$1"

    setup_git_repository "data-activation-producer-wrapper" "${repo_branch}" "https://github.com/adgear/data-activation-producer-wrapper" "ROOT_DATA_ACTIVATION"

    ROOT_DEV_RUN="${ROOT_DATA_ACTIVATION}/dev-run.sh"
    ROOT_SQL_PREQA_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/creatives/preqa_creatives.sql
    ROOT_SQL_TEST_TVS_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/test_tvs_creatives/test_tvs_creatives.sql
    ROOT_SQL_CREATIVES_STRATEGY=${ROOT_DATA_ACTIVATION}/transformation/creatives/creativesStrategy.go
    ROOT_TEST_TVS_CREATIVES="${ROOT_DATA_ACTIVATION}/transformation/test_tvs_creatives.go"
    ROOT_METRIX_INFLUXDB="${ROOT_DATA_ACTIVATION}/pkg/common_packages/metric/influxdb.go"
    verify_file_exists ${ROOT_SQL_PREQA_CREATIVES}
    verify_file_exists ${ROOT_SQL_TEST_TVS_CREATIVES}
    verify_file_exists ${ROOT_SQL_CREATIVES_STRATEGY}
    verify_file_exists ${ROOT_DEV_RUN}
    verify_file_exists ${ROOT_TEST_TVS_CREATIVES}
    verify_file_exists ${ROOT_METRIX_INFLUXDB}

    # Rename to backup/setup
    _da_dev_run=${output_backup}/dev-run.sh
    _da_sql_preqa_creatives=${output_backup}/preqa_creatives.sql
    _da_sql_preqa_creatives_orig=${output_backup}/preqa_creatives.sql.orig
    _da_sql_ttc=${output_backup}/test_tvs_creatives.sql
    _da_sql_ttc_orig=${output_backup}/test_tvs_creatives.sql.orig
    _da_sql_creatives_strategy_orig=${output_backup}/creativesStrategy.go.orig
    _da_test_tvs_creatives=${output_backup}/test_tvs_creatives.go
    _da_metrix_influx_db=${output_backup}/influxdb.go
}


function setup_data_activation() {
    # Modify preqa_creatives.sql to get affected creatives
    local creative_ids_list=$(IFS=', '; echo "${CREATIVES_IDS[*]}")
    local sql_creative_limitation_for_preqa_creatives="vw_creatives.id IN ($creative_ids_list)"
    local sql_creative_limitation_for_tvs="creative_id IN ($creative_ids_list)"

    cp ${ROOT_DEV_RUN} ${_da_dev_run}
    cp ${ROOT_SQL_PREQA_CREATIVES} ${_da_sql_preqa_creatives_orig}
    cp ${ROOT_SQL_TEST_TVS_CREATIVES} ${_da_sql_ttc_orig}
    cp ${ROOT_SQL_CREATIVES_STRATEGY} ${_da_sql_creatives_strategy_orig}
    cp ${ROOT_TEST_TVS_CREATIVES} ${_da_test_tvs_creatives}
    cp ${ROOT_METRIX_INFLUXDB} ${_da_metrix_influx_db}

    # Replace in dev-run.sh to avoid S3 uploads
    sed -i -r -e "s|(^\s+)(aws s3 cp.*)|\1\# \2|g" ${ROOT_DEV_RUN}

    # Replace influxdb to avoid metrics sending
    sed -i -r -e "s/^(\s*func.*(Incr|Count).*\{).*/\1 return/g" ${ROOT_METRIX_INFLUXDB}
    if ! command grep -qe "func.*Incr.*return" "${ROOT_METRIX_INFLUXDB}" ; then
        print_warning "Failed to modify 'Incr' in ${ROOT_METRIX_INFLUXDB} to not send metrics"
    fi
    if ! command grep -qe "func.*Count.*return" "${ROOT_METRIX_INFLUXDB}" ; then
        print_warning "Failed to modify 'Count' in ${ROOT_METRIX_INFLUXDB} to not send metrics"
    fi

    # Replace in preqa_creatives.sql
    sed -i -r -e "/WHERE\s+.*/d" "${ROOT_SQL_PREQA_CREATIVES}"
    sed -i -r -e "s|(ORDER BY.*)|WHERE ${sql_creative_limitation_for_preqa_creatives}\n\1|" "${ROOT_SQL_PREQA_CREATIVES}"

    # replace in test_tvs_creatives.sql
    if command grep -q -E "\s*WHERE" ${ROOT_SQL_TEST_TVS_CREATIVES}; then
        sed -i -r -e "s|WHERE\s*(test_tvs.*)|WHERE ${sql_creative_limitation_for_tvs} AND \1|" "${ROOT_SQL_TEST_TVS_CREATIVES}"
        sed -i -r -e "s|WHERE\s*creative_id.*AND\s+(.*)|WHERE ${sql_creative_limitation_for_tvs} AND \1|" "${ROOT_SQL_TEST_TVS_CREATIVES}"
        sed -i -r -e "s|(\s*)WHERE creative_id IN .*\)|\1WHERE ${sql_creative_limitation_for_tvs}|" "${ROOT_SQL_TEST_TVS_CREATIVES}"
    else
        sed -i -r -e "s|(\s*)(GROUP.*)|\1WHERE ${sql_creative_limitation_for_tvs}\n\1\2|" "${ROOT_SQL_TEST_TVS_CREATIVES}"
    fi

    # Verify sed correctness
    if ! command grep -q "${sql_creative_limitation_for_preqa_creatives}" "${ROOT_SQL_PREQA_CREATIVES}" ; then
        print_error "Failed to modify ${ROOT_SQL_PREQA_CREATIVES} to limit to focused creatives"
        exit 1
    fi

    # HOPE: this is just temporary substitiution
    # TODO: Add limitation to test_devices_creatives
    # sed -i -r -e "s|sql/test_devices_creatives/test_devices_creatives.sql|sql/test_tvs_creatives/test_tvs_creatives.sql|" ${ROOT_TEST_TVS_CREATIVES}
    # if ! command grep -q "test_tvs_creatives.sql" "${ROOT_TEST_TVS_CREATIVES}" ; then
    #     echo "ERROR: Failed to modify ${ROOT_TEST_TVS_CREATIVES} to focus on creatives"
    #     exit 1
    # fi

    # Modify creativesStrategy.go to disable S3 upload
    sed -i -r -e "s|(\s+)(WriteToS3.*filepath)|\1//\2|" ${ROOT_SQL_CREATIVES_STRATEGY}

    cp ${ROOT_SQL_PREQA_CREATIVES} ${_da_sql_preqa_creatives}
    cp ${ROOT_SQL_TEST_TVS_CREATIVES} ${_da_sql_ttc}

    if ! command grep -q "${sql_creative_limitation_for_tvs}" "${ROOT_SQL_TEST_TVS_CREATIVES}" ; then
        print_error "Failed to modify ${ROOT_SQL_TEST_TVS_CREATIVES} to limit to focused creatives"
        exit 1
    fi

    ROOT_GENERATED_DATA=${ROOT_DATA_ACTIVATION}/data-activation
    ROOT_GENERATED_DATA_PREQUA_CREATIVES_TERM=${ROOT_GENERATED_DATA}/preqa_creatives/term
    ROOT_GENERATED_TEST_TV_PARQUET=${ROOT_GENERATED_DATA}/test_tvs_creatives/parquet/test_tvs_creatives.parquet
    ROOT_GENERATED_PREQA_CREATIVES_PARQUET=${ROOT_GENERATED_DATA}/preqa_creatives/parquet/preqa_creatives.parquet
    ROOT_GENERATED_LOCALIZATION_PARQUET=${ROOT_GENERATED_DATA}/localization/parquet/localization.parquet
}

function generate_test_tv_data(){
    print_info "Generating Test TV data..."
    rm -f ${ROOT_GENERATED_TEST_TV_PARQUET}
    cd ${ROOT_DATA_ACTIVATION}
    ${ROOT_DEV_RUN} test_tvs_creatives &> ${OUTPUT}/logs/data-activation-test_tvs.txt
    if [ ! -e ${ROOT_GENERATED_TEST_TV_PARQUET} ]; then
        echo "Failed to generate test_tvs_creatives parquet. Exiting ..." && exit 1
    fi
    print_info "Generated parquet for test_tvs: ${COLOR_GREEN}${ROOT_GENERATED_TEST_TV_PARQUET}${COLOR_RESET}"
}

function generate_preqa_creatives_data(){
    print_info "Generating preqa creatives data..."
    rm -f ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET}
    cd ${ROOT_DATA_ACTIVATION}
    ${ROOT_DEV_RUN} preqa_creatives &> ${OUTPUT}/logs/data-activation-preqa-creatives.txt
    if [ ! -e ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ]; then
        print_error "Failed to generate preqa_creatives parquet. Exiting ..." && exit 1
    fi
}

function generate_localization_data(){
    print_info "Generating localization data..."
    cd ${ROOT_DATA_ACTIVATION}
    rm -f ${ROOT_GENERATED_LOCALIZATION_PARQUET}
    ${ROOT_DEV_RUN} localization &> ${OUTPUT}/logs/data-activation-localization.txt
    if [ ! -e ${ROOT_GENERATED_LOCALIZATION_PARQUET} ]; then
        print_error "Failed to generate localization parquet. Exiting ..." && exit 1
    fi
}

function convert_da_parquet_to_json() {
    ${PYTHON} ${PYTHON_PARQUET_TO_JSON} ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${OUTPUT_JSON_CREATIVES}
    ${PYTHON} ${PYTHON_PARQUET_TO_JSON} ${ROOT_GENERATED_TEST_TV_PARQUET} ${OUTPUT_TEST_TVS}
    print_info "Output in json for preqa_creatives: ${COLOR_GREEN}${OUTPUT_JSON_CREATIVES}${COLOR_RESET}"
    print_info "Output in json for test_tvs_creatives: ${COLOR_GREEN}${OUTPUT_TEST_TVS}${COLOR_RESET}"
}

function process_term_bert_files() {
    print_info "Processing term bert files ..."
    term_files=$(find ${ROOT_GENERATED_DATA_PREQUA_CREATIVES_TERM}/ -type f -name "*.term" | xargs)

    for creative_id in ${CREATIVES_IDS[@]}; do
        local creative_term_file="${output_artifacts}/${creative_id}_term.term"
        local creative_bert_file="${output_artifacts}/${creative_id}_bert.bert2"
        touch ${creative_term_file} ${creative_bert_file}
        term_file_found=false
        for term_file in $term_files; do
            if grep -q "$creative_id" "${term_file}"; then
                term_file_found=true
                bert_file=$(dirname ${term_file})/creatives.bert2
                cp ${term_file} ${creative_term_file}
                # print_info "For ${creative_id} generated term file: ${creative_term_file}"
                CREATIVES_TERM+=("${creative_term_file}")

                if [[ -e ${bert_file} ]]; then
                    cp ${bert_file} ${creative_bert_file}
                    CREATIVES_BERT+=("${creative_bert_file}")
                    # print_info "For ${creative_id} generated bert file: ${creative_bert_file}"
                else
                    $DEBUG && print_warning "For ${creative_id} cannot find bert file: ${creative_bert_file}"
                    CREATIVES_BERT+=("${creative_bert_file}${EMPTY_MARK}")
                fi
                break
            fi
        done
        if [ "$term_file_found" = false ]; then
            print_error "No term and bert files found for creative_id $creative_id"
            CREATIVES_BERT+=("${creative_bert_file}${EMPTY_MARK}")
            CREATIVES_TERM+=("${creative_term_file}${EMPTY_MARK}")
        fi
    done
}

function parse_parquet_files() {
    while IFS= read -r line; do
        id=$(echo "$line" | jq -r '.Id')
        creative_parquet_out_json=${output_artifacts}/${id}_da_json.json
        echo $line | jq --indent 2 . &> ${creative_parquet_out_json}
        # print_info "For creative_id: $id parquet file: ${creative_parquet_out_json}"
        CREATIVES_PARQUETS+=("${creative_parquet_out_json}")

    done < ${OUTPUT_JSON_CREATIVES}
}
