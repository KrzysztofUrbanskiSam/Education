# Colors
COLOR_RESET="\033[0m"   # reset
HC="\033[1m"            # bold
COLOR_RED="\033[31m"    # foreground red
COLOR_GREEN="\033[32m"  # foreground green
COLOR_YELLOW="\033[33m" # foreground yellow
COLOR_BLUE="\033[34m"   # foreground yellow

function print_debug() {
    ${DEBUG} && echo -e "DEBUG: $1"
}

function print_info() {
    echo -e "INFO: $1"
}

function print_info_color() {
    echo -e "${COLOR_BLUE}INFO: $1${COLOR_RESET}"
}

function print_warning() {
    echo -e "${FYEL}WARNING: $1${COLOR_RESET}"
}

function print_error() {
    echo -e "${COLOR_RED}ERROR: $1${COLOR_RESET}"
}

function print_critical() {
    echo -e "${COLOR_RED}CRITICAL: $1${COLOR_RESET}"
    exit 1
}