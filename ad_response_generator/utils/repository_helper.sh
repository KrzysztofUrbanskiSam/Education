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
            echo "ERROR: Failed to pull '${default_branch}' for '${repo_path}'. Error log:"
            cat ${pull_log}
            exit 1
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

    echo "INFO: Setuping repository ${repo_name}"
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

function print_repository_status() {
    for repo_path in "$@"; do
        cd ${repo_path}
        repo_name=$(basename ${repo_path})
        repo_branch=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s|* \(.*\)|\1|")
        commit_msg=$(git log -1 --pretty=format:'%s')
        repo_updated=$(git log -1 --pretty=format:'%cr')
        # printf "INFO: %-32s - %-17s %s\n" "${repo_name}" "${repo_metadata}" "${repo_branch}"
        echo -e "INFO: Repo name: ${repo_name}"
        echo -e "INFO:\tRepo branch: ${repo_branch}"
        echo -e "INFO:\tCommits msg: ${commit_msg}"
        echo -e "INFO:\tCommit hash: $(git rev-parse HEAD)"
        echo -e "INFO:\tUpdated: ${repo_updated}"
    done
}
