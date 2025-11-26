# Conisder making it as a dictionary
if [[ -z "$ad_response_generator_context" ]]; then
    echo "Cannot invoke outside 'ad_response_generator"
    echo "Run 'bash ad_response_generator <args>'"
    exit 1
fi

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
    print_info "Setting up test TVs ..."
    for creative_id in "${creative_ids[@]}"; do
        local creative_data=$(execute_sql_query "SELECT type, creative_subtype_id, life_stage, name FROM creatives WHERE id='$creative_id';")
        local creative_type=$(echo $creative_data | cut -d',' -f1 | xargs)
        local creative_subtype=$(echo $creative_data | cut -d',' -f2 | xargs)
        local creative_lifestage=$(echo $creative_data | cut -d',' -f3 | xargs)
        local creative_name=$(echo $creative_data | cut -d',' -f4 | xargs)

        if [[ -z "${creative_data}" ]]; then
            print_error "Creative ${creative_id} does not exist in database. Exiting..."
            exit 1
        fi

        if [[ ${creative_lifestage} != "ready" ]]; then
            print_warning "Creative ${creative_id} is not 'ready'. Automatic transcoding will be performed (may take 10s)"
            perform_transcoding ${creative_id}

            # Check if transcoding worked
            local creative_lifestage=$(execute_sql_query "SELECT life_stage FROM creatives WHERE id='$creative_id';" | xargs)
            if [[ ${creative_lifestage} != "ready" ]]; then
                print_warning "Failed to automatically transcode creative ${creative_id}."
                creatives_ready=false
                continue
            fi
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
            print_error "For ${creative_id} cannot find pid."
            echo "HINT: Contact script maintainers"
            exit 1
        fi

        # Assign creative_id with dedicated TV
        local creative_test_tv_id=$(execute_sql_query "SELECT test_tv_id FROM test_tvs_creatives WHERE creative_id='$creative_id' AND test_tv_id='${tv_id}';")
        if [[ -z $creative_test_tv_id ]]; then
            $DB_CONNECT -c "INSERT INTO test_tvs_creatives (creative_id, test_tv_id) VALUES ($creative_id, $tv_id);" &> /dev/null
            local creative_test_tv_id=$(execute_sql_query "SELECT test_tv_id FROM test_tvs_creatives WHERE creative_id='$creative_id';" | tr '|' ',' | xargs)
        fi

        CREATIVES_PIDS+=("${creative_pid}")
        CREATIVES_NAMES+=("${creative_name}")
        TVS_PSIDS+=("$tv_psid")
        $DEBUG && print_info "Setup for creative ${creative_id} -> PID:${creative_pid} PSID:${tv_psid}"
    done

    if [[ $creatives_ready != true ]]; then
        print_info "One of provided creative is not ready. Probably needs to be transcoded"
        echo "HINT: To perform transcoding, run rtb-trader and additionally in separate terminal run:"
        echo "HINT: QUEUE=* rails resque:work"
        echo "HINT: Open your creative, save again, refresh preview page, and notice 'green dot' indicating creative is ready."
        exit 1
    fi

    if [[ ${#TVS_PSIDS[@]} == 0 ]]; then
        print_error "Provided creatives were not set up properly. Exiting... "
        exit 1
    fi
}
