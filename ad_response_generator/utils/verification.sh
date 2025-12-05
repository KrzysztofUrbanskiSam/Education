if [[ -z "$ad_response_generator_context" ]]; then
    echo "Cannot invoke outside 'ad_response_generator"
    echo "Run 'bash ad_response_generator <args>'"
    exit 1
fi

startup_startup_verification_success=true

function do_verify_input_arguments(){
    if [[ ${#CREATIVES_IDS[@]} -eq 0 ]]; then
        print_error "No creative IDs provided"
        startup_verification_success=false
    fi

    for id in "${CREATIVES_IDS[@]}"; do
        if [[ ! $id =~ ^[0-9]+$ ]]; then
            print_error "Invalid creative ID: $id (must be numeric)"
            startup_verification_success=false
        fi
    done
}

function do_verify_github_setup(){
    if ! command cat $ROOT_BIDDER/.git/config 2>/dev/null | grep rtb-bidder.git &>/dev/null ; then
        print_error "Set 'ROOT_BIDDER' pointing to root of rtb-bidder repository"
        print_info "Please pull repo from: https://github.com/adgear/rtb-bidder"
        startup_verification_success=false
    fi

    if ! command echo $GOPRIVATE | grep "github.com/adgear" &> /dev/null; then
        print_error "Set GOPRIVATE environment variable to include github.com/adgear"
        echo "HINT: Do this by adding 'export GOPRIVATE=\"github.com/adgear\"' to your ~/.bashrc file"
        startup_verification_success=false
    fi

    if ! command echo $GOPROXY | grep "https://proxy.golang.org" | grep direct &> /dev/null; then
        print_error "Set GOPROXY environment variable to include 'https://proxy.golang.org' and 'direct'"
        echo "HINT: Do this by adding 'export GOPROXY=\"https://proxy.golang.org,direct\"' to your ~/.bashrc file"
        startup_verification_success=false
    fi

    if [[ -z "${GITHUB_TOKEN}" ]]; then
        print_error "Set GITHUB_TOKEN environment variable, ideally add to your ~/.bashrc file"
        echo "HINT: To setup GITHUB_TOKEN follow instruction: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic"
        startup_verification_success=false
    fi
}

function do_verify_installed_programs(){
    if ! command -v go &> /dev/null; then
        print_error "go is not installed. Please install go to run this script."
        startup_verification_success=false
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install jq to run this script."
        startup_verification_success=false
    fi

    if ! command -v make &> /dev/null; then
        print_error "make is not installed. Please install make to run this script."
        startup_verification_success=false
    fi

    if ! command -v docker &> /dev/null; then
        print_error "docker is not installed. Please install docker to run this script."
        startup_verification_success=false
    fi
    if ! command -v psql &> /dev/null; then
        print_error "psql is not installed. Please install psql to run this script."
        startup_verification_success=false
    fi
    if ! command erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell &> /dev/null; then
        print_warning "Erlang is not installed."
        print_error "Without Erlang it is impossible to generate term data"
        startup_verification_success=false
    fi
}

function do_verify_python(){
    if [[ -e ${PYTHON} ]]; then
        $DEBUG && { echo "DEBUG: Python environment detected"; }
    else
        $DEBUG && { echo "INFO: Python environment not detected. Will try to install (may take 15s)"; }
        python_venv_install_log="${output_logs}/python_env_install.log"
        cd $(dirname ${PYTHON_VENV})
        python3 -m venv .venv &> ${python_venv_install_log}
        source ${PYTHON_VENV}/bin/activate
        pip install pyarrow argparse pandas >> ${python_venv_install_log}
        deactivate
    fi

    $DEBUG && { echo "DEBUG: Python: ${PYTHON}"; }
    if ! command ${PYTHON} -c "import argparse,pyarrow,pandas" &> /dev/null; then
        print_warning "Python3 is not correctly configured. Please install 'argparse', 'pyarrow' and 'pandas'"
        print_warning "Without Python it is impossible to convert data-activation output to JSON"
        startup_verification_success=false
    fi
}

function do_verify_bidder_ports_not_used(){
    # Probably port verifications 3000 and 3002 are not needed. Perhaps only fake-unleash is needed
    # docker_containers=$(docker ps)
    # if command echo "$socket_status" | grep :3000 &> /dev/null; then
    #     if ! command echo "$docker_containers" | grep 3000 | grep aerospike &> /dev/null; then
    #         echo "ERROR: On port 3000 is running something but not 'aerospike', kill that process"
    #         echo "HINT: To kill process use 'sudo kill -9 $(ps -aux | grep "rails s" | grep -v "grep" | cut -d" " -f 2)'"
    #     fi
    # fi
    # if command echo "$socket_status" | grep :3002 &> /dev/null; then
    #     if ! command echo "$docker_containers" | grep 3002 | grep aerospike &> /dev/null; then
    #         echo "ERROR: On port 3002 is running something but not 'aerospike', kill that process"
    #         echo "HINT: To kill process use 'sudo kill -9 $(ps -aux | grep "rails s" | grep -v "grep" | cut -d" " -f 2)'"
    #     fi
    # fi

    socket_status=$(ss -lpt)
    if command echo "$socket_status" | grep :8085 &> /dev/null; then
        print_warning "There is an application working on port 8085. This is Bidder port. May work improperly"
        app_on_port_8085_pid=$(echo "$socket_status" | grep :8085 | grep -oP 'pid=\K\d+')
        echo "HINT: If you want to kill run: 'sudo kill -9 ${app_on_port_8085_pid}'"
    fi
}

function do_verify_trader_db_connection(){
    if ! command $DB_CONNECT -c "SELECT 1;" &>/dev/null; then
        print_error "Failed to connect to database with '${DB_CONNECT}'"
        echo "HINT: Verify connection setup ..."
        echo "HINT: If you run on local machine try:"
        echo "HINT:    cd <PROJECTS_ROOT>/rtb-trader && docker compose up db -d"
        startup_verification_success=false
    fi
}

function do_startup_verification() {
    do_verify_input_arguments
    do_verify_installed_programs
    do_verify_github_setup
    do_verify_python
    do_verify_bidder_ports_not_used
    do_verify_trader_db_connection
}
