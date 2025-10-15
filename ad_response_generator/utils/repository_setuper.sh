function verify_file_exists() {
    if [[ ! -f "$1" ]]; then
        echo "ERROR: Needed file does not exists: $1"
        exit 1
    fi
}

function pull_default_branch() {
    local repo_path="$1"
    local default_branch="$2"
    local current_branch="$3"
    local repo_name=${1##*/}

    if [[ "${current_branch}" == "${default_branch}" ]]; then
        local pull_log="${output_logs}/pull_${repo_name}_${default_branch}.log"
        $DEBUG && { echo "DEBUG: Pulling newest changes for ${repo_path}"; }
        cd ${repo_path}
        if ! command git pull origin "$default_branch" &> ${pull_log}; then
            echo "WARNING: Failed to pull '${default_branch}' for '${repo_path}'"
            echo "HINT: Inspect logs from ${pull_log}. Probably you have unstaged changes"
        fi
    fi
}

function checkout_on_branch() {
    local repo_path="$1"
    local target_branch="$2"
    local current_branch
    local default_branch

    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Error: '$repo_path' is not a git repository"
        exit 1
    fi

    cd $repo_path
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|^refs/remotes/origin/||')

    if [[ -z "${target_branch}" ]]; then
        $DEBUG && { echo "DEBUG: Not changing branch, staying on '${current_branch}'"; }
        return
    fi

    if [[ "$current_branch" == "$target_branch" ]]; then
        $DEBUG && { echo "DEBUG: In '${repo_path}' already on branch '$target_branch'"; }
        pull_default_branch $repo_path $default_branch $current_branch
        return
    fi

   if git show-ref --verify --quiet refs/heads/"$target_branch"; then
        # Branch exists locally
        echo "DEBUG: Checking on local branch '$target_branch'... "
        git checkout "$target_branch" &>/dev/null || {
            echo "ERROR: Failed to checkout local branch '$target_branch'"
            exit 1
        }
    elif git ls-remote --heads origin "$target_branch" | grep -q "$target_branch"; then
        # Branch exists remotely
        echo "DEBUG: Checking on remote branch '$target_branch'... "
        git checkout "$target_branch" &>/dev/null || {
            echo "Error: Failed to checkout remote branch '$target_branch'"
            return 7
        }
    else
        echo "ERROR: For '${repo_path}' branch '$target_branch' does not exist neither locally nor remotely ..."
        exit 1
    fi

    pull_default_branch $repo_path $default_branch $current_branch
}

function locate_repository(){ # $1 = repository name
    local REPO_DIR="/home/k.urbanski/Projects/Education"
    readarray -t REPOS < <(find ${REPO_DIR}/../ -name .git -type d -printf "%h\n")
    for repo in ${REPOS[@]}; do
        if command cat "${repo}/.git/config" | grep "$1.git" &>/dev/null ; then
            echo $(readlink -f "${repo}")
            exit 0
        fi
    done
}

function setup_git_repository() {
    local repo_name="$1"
    local repo_branch="$2"
    local repo_url="$3"
    local root_env_var="$4"

    # Get the value of the root environment variable
    local root_path="${!root_env_var}"

    if [[ -z "${root_path}" ]]; then
        echo "WARNING: Env variable '${root_env_var}' not set. Trying to guess ${repo_name}"
        echo "HINT: Set '${root_env_var}' pointing to root of ${repo_name} repository to avoid search"
        root_path=$(locate_repository "${repo_name}")
    fi

    if ! command cat $root_path/.git/config 2>/dev/null | grep "${repo_name}.git" &>/dev/null ; then
        echo "ERROR: Set '${root_env_var}' pointing to root of ${repo_name} repository"
        echo "INFO: Please pull repo from: ${repo_url}"
        exit 1
    fi

    export ${root_env_var}=${repo_path}
    eval "export ${root_env_var}=\"${root_path}\""
    checkout_on_branch ${root_path} ${repo_branch}
}

function setup_bidder_parquet() {
    cd ${ROOT_BIDDER}

    # flights.parquet is just and example of file that should be present after running'make parquet' command
    if [ ! -e "${ROOT_BIDDER}/test/data-activation/data/flights.parquet" ]; then
        echo "INFO: Populating bidder with 'make parquet' command"
        make parquet &> ${output_logs}/bidder_make_parquet.log
        if [ ! -e "${ROOT_BIDDER}/test/data-activation/data/flights.parquet" ]; then
            echo "ERROR: Populating bidder with 'make parquet' command"
            echo "INFO: Inspect log ${output_logs}/bidder_make_parquet.log"
            exit 1
        fi
    fi
}

function setup_bidder_geoip(){
    local correct_geoip=true
    geoip_files=("/usr/share/GeoIP/DE-CountryISO-DB.mmdb" "/usr/share/GeoIP/GeoIP2-Connection-Type.mmdb" "/usr/share/GeoIP/GeoIP2-ISP.mmdb")
    for f in ${geoip_files[@]}; do
        if [ ! -e "$f" ]; then
            echo "ERROR: Missing GeoIP file: $f"
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

    sed -i -r -e "s|^\s+(-.*fake-barker)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|^\s+(-.*userprofileservice)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|^\s+(-.*crossdeviceprofile)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|^\s+(-.*fake-ups)|# \1|" ${ROOT_BIDDER_DOCKER_COMPOSE}
    sed -i -r -e "s|url:\s*.*unleash.*|url: http://localhost:51000|g" ${ROOT_BIDDER_CONFIG_LOCAL}
    sed -i '/^familyhub:$/ { n; s/true/false/ }' ${ROOT_BIDDER_CONFIG_LOCAL}
    sed -i -r -e "s|(^run-rtb-bidder:).*(#.*)|\1 \2|" ${ROOT_BIDDER}/Makefile
    sed -i -r -e "/docker compose.*docker-compose.yml logs/d" ${ROOT_BIDDER}/Makefile
}

function setup_bidder_branch() {
    local repo_branch="$1"

    setup_git_repository "rtb-bidder" "${repo_branch}" "https://github.com/adgear/rtb-bidder" "ROOT_BIDDER"

    ROOT_BIDDER_DOCKER_COMPOSE=${ROOT_BIDDER}/docker/bidder/docker-compose.deps.yml
    ROOT_BIDDER_CONFIG_LOCAL=${ROOT_BIDDER}/configs/bidder/default-local.yaml
    verify_file_exists ${ROOT_BIDDER_DOCKER_COMPOSE}
    verify_file_exists ${ROOT_BIDDER_CONFIG_LOCAL}


    _bidder_docker_compose_orig=${OUTPUT}/docker-compose.deps.yml
    _bidder_config_local_orig=${OUTPUT}/default-local.yaml
}

function setup_da_branch() {
    local repo_branch="$1"

    setup_git_repository "data-activation-producer-wrapper" "${repo_branch}" "https://github.com/adgear/data-activation-producer-wrapper" "ROOT_DATA_ACTIVATION"

    ROOT_SQL_PREQA_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/creatives/preqa_creatives.sql
    ROOT_SQL_TEST_TVS_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/test_tvs_creatives/test_tvs_creatives.sql
    ROOT_SQL_CREATIVES_STRATEGY=${ROOT_DATA_ACTIVATION}/transformation/creatives/creativesStrategy.go
    verify_file_exists ${ROOT_SQL_PREQA_CREATIVES}
    verify_file_exists ${ROOT_SQL_TEST_TVS_CREATIVES}
    verify_file_exists ${ROOT_SQL_CREATIVES_STRATEGY}

    # Rename to backup/setup
    _da_sql_preqa_creatives=${output_backup}/preqa_creatives.sql
    _da_sql_preqa_creatives_orig=${output_backup}/preqa_creatives.sql.orig
    _da_sql_ttc=${output_backup}/test_tvs_creatives.sql
    _da_sql_ttc_orig=${output_backup}/test_tvs_creatives.sql.orig
}


function setup_data_activation(){
    # Modify preqa_creatives.sql to get affected creatives
    local creative_ids_list=$(IFS=', '; echo "${CREATIVES_IDS[*]}")
    local sql_creative_limitation_for_preqa_creatives="vw_creatives.id IN ($creative_ids_list)"
    local sql_creative_limitation_for_tvs="creative_id IN ($creative_ids_list)"

    cp ${ROOT_SQL_PREQA_CREATIVES} ${_da_sql_preqa_creatives_orig}
    cp ${ROOT_SQL_TEST_TVS_CREATIVES} ${_da_sql_ttc_orig}

    # Replace in preqa_creatives.sql
    sed -i -r -e "/WHERE\s+.*/d" "${ROOT_SQL_PREQA_CREATIVES}"
    sed -i -r -e "s|(ORDER BY.*)|WHERE ${sql_creative_limitation_for_preqa_creatives}\n\1|" "${ROOT_SQL_PREQA_CREATIVES}"

    # replace in test_tvs_creatives.sql
    sed -i -r -e "s|WHERE\s+(test_tvs.*)|WHERE ${sql_creative_limitation_for_tvs} AND \1|" "${ROOT_SQL_TEST_TVS_CREATIVES}"
    sed -i -r -e "s|WHERE\s+creative_id.*AND\s+(.*)|WHERE ${sql_creative_limitation_for_tvs} AND \1|" "${ROOT_SQL_TEST_TVS_CREATIVES}"

    # HOPE: this is just temporary substitiution
    sed -i -r -e "s|sql/test_devices_creatives/test_devices_creatives.sql|sql/test_tvs_creatives/test_tvs_creatives.sql|" ${ROOT_DATA_ACTIVATION}/transformation/test_tvs_creatives.go

    cp ${ROOT_SQL_PREQA_CREATIVES} ${_da_sql_preqa_creatives}
    cp ${ROOT_SQL_TEST_TVS_CREATIVES} ${_da_sql_ttc}

    # Verify sed correctness
    if ! command grep -q "${sql_creative_limitation_for_preqa_creatives}" "${ROOT_SQL_PREQA_CREATIVES}" ; then
        echo "ERROR: Failed to modify ${ROOT_SQL_PREQA_CREATIVES} to limit to focused creatives"
        exit 1
    fi

    if ! command grep -q "${sql_creative_limitation_for_tvs}" "${ROOT_SQL_TEST_TVS_CREATIVES}" ; then
        echo "ERROR: Failed to modify ${ROOT_SQL_TEST_TVS_CREATIVES} to limit to focused creatives"
        exit 1
    fi

    ROOT_GENERATED_DATA=${ROOT_DATA_ACTIVATION}/data-activation
    ROOT_GENERATED_TEST_TV_PARQUET=${ROOT_GENERATED_DATA}/test_tvs_creatives/parquet/test_tvs_creatives.parquet
    ROOT_GENERATED_PREQA_CREATIVES_PARQUET=${ROOT_GENERATED_DATA}/preqa_creatives/parquet/preqa_creatives.parquet
    ROOT_GENERATED_LOCALIZATION_PARQUET=${ROOT_GENERATED_DATA}/localization/parquet/localization.parquet
}