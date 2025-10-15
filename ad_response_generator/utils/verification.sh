function do_verification() {
    local verification_success=true
    if [[ ${#CREATIVES_IDS[@]} -eq 0 ]]; then
        echo "ERROR: No creative IDs provided"
        verification_success=false
    fi

    for id in "${CREATIVES_IDS[@]}"; do
        if [[ ! $id =~ ^[0-9]+$ ]]; then
            echo "ERROR: Invalid creative ID: $id (must be numeric)"
            verification_success=false
        fi
    done

    if ! command cat $ROOT_BIDDER/.git/config 2>/dev/null | grep rtb-bidder.git &>/dev/null ; then
        echo "ERROR: Set 'ROOT_BIDDER' pointing to root of rtb-bidder repository"
        echo "INFO: Please pull repo from: https://github.com/adgear/rtb-bidder"
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

    if ! command -v make &> /dev/null; then
        echo "ERROR: make is not installed. Please install make to run this script."
        verification_success=false
    fi

    if ! command -v docker &> /dev/null; then
        echo "ERROR: docker is not installed. Please install docker to run this script."
        verification_success=false
    fi

    if ! command echo $GOPRIVATE | grep "github.com/adgear" &> /dev/null; then
        echo "ERROR: Set GOPRIVATE environment variable to include github.com/adgear"
        echo "HINT: Do this by adding 'export GOPRIVATE=\"github.com/adgear\"' to your ~/.bashrc file"
        verification_success=false
    fi

    if ! command echo $GOPROXY | grep "https://proxy.golang.org" | grep direct &> /dev/null; then
        echo "ERROR: Set GOPROXY environment variable to include 'https://proxy.golang.org' and 'direct'"
        echo "HINT: Do this by adding 'export GOPROXY=\"https://proxy.golang.org,direct\"' to your ~/.bashrc file"
        verification_success=false
    fi

    if [[ -z "${GITHUB_TOKEN}" ]]; then
        echo "ERROR: Set GITHUB_TOKEN environment variable, ideally add to your ~/.bashrc file"
        echo "HINT: To setup GITHUB_TOKEN follow instruction: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic"
        verification_success=false
    fi

    if ! command -v psql &> /dev/null; then
        echo "ERROR: psql is not installed. Please install psql to run this script."
        verification_success=false
    fi

    if ! command $DB_CONNECT -c "SELECT 1;" &>/dev/null; then
        echo "ERROR: Failed to connect to database with '${DB_CONNECT}'"
        echo "HINT: Verify connection setup"
        verification_success=false
    fi

    if command ss | grep :3000 &> /dev/null; then
        echo "WARNING: There is an application working on port 3000. Script may work improperly"
        if ! command docker ps | grep :3000 | grep aerospike &> /dev/null; then
            echo "ERROR: On port 3000 is running something but not 'aerospike', kill that process"
            echo "HINT: To kill process use 'sudo kill -9 $(ps -aux | grep "bin/rails s" | grep -v "grep" | cut -d" " -f 2)'"
        fi
    fi

    if [ ! $verification_success == true ]; then
        echo "INFO: Please correct missing setup and rerun the script"
        exit 1
    fi

    if ! command ${PYTHON} -c "import argparse,pyarrow" &> /dev/null; then
        echo "WARNING: Python3 is not correctly configured. Please install argparse and pyarrow"
        echo "HINT: Without Python it is impossible to convert data-activation output to JSON"
    fi

    if ! command erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell &> /dev/null; then
        echo "WARNING: Erlang is not installed."
        echo "HINT: Without Erlang it is impossible to generate term data"
    fi

    if command ss | grep 8085 &> /dev/null; then
        echo "WARNING: There is an application working on port 8085. Script may work improperly"
    fi

    [ -e $OUTPUT ] && rm -rf ${OUTPUT}
    echo "INFO: Output directory: $OUTPUT"
    mkdir -p $output_ad_requests $output_ad_responses $output_artifacts $output_logs $output_setup $output_backup
}