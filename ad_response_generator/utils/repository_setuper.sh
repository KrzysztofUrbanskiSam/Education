function pull_default_branch() {
    local repo_path="$1"
    local default_branch="$2"
    local current_branch="$3"

    if [[ "${current_branch}" == "${default_branch}" ]]; then
        echo "DEBUG: Pulling newest changes for ${repo_path}"
        cd ${repo_path} && git pull origin "$default_branch" &>/dev/null
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
        echo "DEBUG: Not changing branch, staying on '${current_branch}'"
        return
    fi

    if [[ "$current_branch" == "$target_branch" ]]; then
        echo "DEBUG: In '${repo_path}' already on branch '$target_branch'"
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

function setup_bidder_branch() {
    local repo_branch="$1"
    checkout_on_branch ${ROOT_DATA_ACTIVATION} ${repo_branch}
}

function setup_da_branch() {
    local repo_branch="$1"

    if [[ -z "${ROOT_DATA_ACTIVATION}" ]]; then
        echo "WARNING: Env variable 'ROOT_DATA_ACTIVATION' not set. Trying to guess data-activation-producer-wrapper"
        echo "HINT: Set 'ROOT_DATA_ACTIVATION' pointing to root of data-activation-producer-wrapper repository to avoid search"
        ROOT_DATA_ACTIVATION=$(locate_repository 'data-activation-producer-wrapper')
    fi

    if ! command cat $ROOT_DATA_ACTIVATION/.git/config 2>/dev/null | grep data-activation-producer-wrapper.git &>/dev/null ; then
        echo "ERROR: Set 'ROOT_DATA_ACTIVATION' pointing to root of data-activation-producer-wrapper repository"
        echo "INFO: Please pull repo from: https://github.com/adgear/data-activation-producer-wrapper"
        exit 1
    fi

    checkout_on_branch ${ROOT_DATA_ACTIVATION} ${repo_branch}

    ROOT_SQL_PREQA_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/creatives/preqa_creatives.sql
    ROOT_SQL_TEST_TVS_CREATIVES=${ROOT_DATA_ACTIVATION}/sql/test_tvs_creatives/test_tvs_creatives.sql
    ROOT_SQL_CREATIVES_STRATEGY=${ROOT_DATA_ACTIVATION}/transformation/creatives/creativesStrategy.go
    _da_sql_preqa_creatives=${OUTPUT}/preqa_creatives.sql
    _da_sql_preqa_creatives_orig=${OUTPUT}/preqa_creatives.sql.orig
    _da_sql_ttc=${OUTPUT}/test_tvs_creatives.sql
    _da_sql_ttc_orig=${OUTPUT}/test_tvs_creatives.sql.orig
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
    exit 1
}