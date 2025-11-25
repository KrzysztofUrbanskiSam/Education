function setup_bidder_parquet() {
    cd ${ROOT_BIDDER}

    echo "INFO: Populating bidder with 'make parquet' command"
    make parquet &> ${output_logs}/bidder_make_parquet.log
    if [ ! -e "${ROOT_BIDDER}/test/data-activation/data/flights.parquet" ]; then
        print_error "Populating bidder with 'make parquet' command"
        echo "INFO: Inspect log ${output_logs}/bidder_make_parquet.log"
        exit 1
    fi
}

function setup_bidder_geoip(){
    local correct_geoip=true
    geoip_files=("/usr/share/GeoIP/DE-CountryISO-DB.mmdb" "/usr/share/GeoIP/GeoIP2-Connection-Type.mmdb" "/usr/share/GeoIP/GeoIP2-ISP.mmdb")
    for f in ${geoip_files[@]}; do
        if [ ! -e "$f" ]; then
            print_error "Missing GeoIP file: $f"
            correct_geoip=false
        fi
    done

    #TODO: Consider replacing usage of /usr/share/GeoIP so not 'sudo' directory would be needed
    #      Right now script is not adjsuted (and probably will never be) to run with sudo permissions
    if [ "$correct_geoip" = false ]; then
        echo "HINT: sudo mkdir -p /usr/share/GeoIP/ && sudo cp -f ${ROOT_BIDDER}/test/data-activation/data/GeoIP/* /usr/share/GeoIP/"
        exit 1
    fi
}

function setup_bidder(){
    cd ${ROOT_BIDDER}

    setup_bidder_parquet
    setup_bidder_geoip

    cp ${ROOT_BIDDER_DOCKER_COMPOSE} ${_bidder_docker_compose_orig}
    cp ${ROOT_BIDDER_CONFIG_LOCAL} ${_bidder_config_local_orig}
    cp ${ROOT_BIDDER_APP_GO} ${_bidder_app_go_orig}

    sed -i -r -e "s|^\s+(-.*fake-barker)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|^\s+(-.*userprofileservice)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|^\s+(-.*crossdeviceprofile)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|^\s+(-.*fake-ups)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|(\s*err\s*:=\s*)unleashclient.InitializeUnleashClient.*|\1error(nil)|" "${ROOT_BIDDER_APP_GO}"
    sed -i '/^event_publisher:$/ { n; s/true/false/ }' ${ROOT_BIDDER_CONFIG_LOCAL}
    sed -i -r -e 's|(\s*)loopinterval: 10s|\1loopinterval: 10000000s|' ${ROOT_BIDDER_CONFIG_LOCAL}
    sed -i -r -e "s|(\s+host:\s*\")localhost:8085\"|\1rtb-canary.adgrx.com\"|" ${ROOT_BIDDER_CONFIG_LOCAL}
    sed -i '/^familyhub:$/ { n; s/true/false/ }' ${ROOT_BIDDER_CONFIG_LOCAL}

    # No longer needed but keep it here
    # sed -i -r -e "s|url:\s*.*unleash.*|url: http://localhost:51000|g" ${ROOT_BIDDER_CONFIG_LOCAL}
    # sed -i -r -e "s|(^run-rtb-bidder:).*(#.*)|\1 \2|" ${ROOT_BIDDER}/Makefile
    # sed -i -r -e "/docker compose.*docker-compose.yml logs/d" ${ROOT_BIDDER}/Makefile
}

function setup_bidder_branch() {
    local repo_branch="$1"

    setup_git_repository "rtb-bidder" "${repo_branch}" "https://github.com/adgear/rtb-bidder" "ROOT_BIDDER"

    ROOT_BIDDER_DOCKER_COMPOSE=${ROOT_BIDDER}/docker/bidder/docker-compose.deps.yml
    ROOT_BIDDER_CONFIG_LOCAL=${ROOT_BIDDER}/configs/bidder/default-local.yaml
    ROOT_BIDDER_APP_GO=${ROOT_BIDDER}/internal/bidder/app/app.go
    verify_file_exists ${ROOT_BIDDER_DOCKER_COMPOSE}
    verify_file_exists ${ROOT_BIDDER_CONFIG_LOCAL}
    verify_file_exists ${ROOT_BIDDER_APP_GO}

    _bidder_docker_compose_orig=${OUTPUT}/docker-compose.deps.yml
    _bidder_config_local_orig=${OUTPUT}/default-local.yaml
    _bidder_app_go_orig=${OUTPUT}/app.go
}

function populate_bidder_with_data() {
    echo "INFO: Populating bidder with DA data ..."
    if [ ! -e ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ]; then
        print_error "Generated 'preqa_creatives' data not found."
        if [[ $REFRESH_DA_DATA == false ]]; then
            echo "HINT: Rerun script without '--no-da-refresh' flag"
        fi
        exit 1
    fi
    cp ${ROOT_GENERATED_TEST_TV_PARQUET} ${ROOT_BIDDER}/test/data-activation/data
    cp ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/preqa_creatives.parquet
    cp ${ROOT_GENERATED_PREQA_CREATIVES_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/creatives.parquet
    if [ ${TV_LANGUAGE} != "en" ]; then
        if [ ! -e ${ROOT_GENERATED_LOCALIZATION_PARQUET} ]; then
            cp ${ROOT_GENERATED_LOCALIZATION_PARQUET} ${ROOT_BIDDER}/test/data-activation/data/localization.parquet
        else
            print_warning "Localization parquet file not found. Default 'Ad language' will be 'en'"
        fi
    fi
}

function run_bidder(){
    echo "INFO: Starting bidder ..."
    cd ${ROOT_BIDDER}
    go run ${ROOT_BIDDER}/cmd/bidder/ -configFile ${ROOT_BIDDER_CONFIG_LOCAL} &> ${OUTPUT}/logs/bidder.txt
}
