#!/bin/bash

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --creatives-ids)
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                    CREATIVES_IDS+=("$1")
                    shift
                done
                ;;
            --branch-bidder)
                shift; BRANCH_BIDDER="$1"; shift ;;
            --branch-data-activation | --branch-da)
                shift; BRANCH_DA="$1"; shift ;;
            --db-*)
                local param="${1#--db-}"
                shift; eval "DB_${param^^}=\"$1\""; shift ;;
            --language)
                shift; TV_LANGUAGE="$1"; shift ;;
            --no-da-refresh)
                REFRESH_DA_DATA=false; shift ;;
            --only-setup-repos)
                ONLY_SETUP_REPOSITORIES=true; shift ;;
            --only-da-artifacts)
                ONLY_DA=true; shift ;;
            --no-undo-changes)
                UNDO_CHANGES=false; shift ;;
            --ui-mode)
                UI_MODE=true; shift ;;
            --debug)
                DEBUG=true; shift ;;
            --output)
                shift; OUTPUT="$1"; shift ;;
            *)
                echo "CRITICAL: Provided unknown option: $1"; show_usage ; exit 1 ;;

        esac
    done
}

function show_usage() {
    echo "Usage: $0 [ARGUMENTS] [OPTIONS]"
    echo "Arguments:"
    echo "  --creatives-ids id1 id2 ...       List of creative IDs"
    echo ""
    echo "Options:"
    echo "  --branch-bidder BRANCH            Bidder branch name (default: main)"
    echo "  --branch-data-activation BRANCH   Data activation branch name (default: master)"
    echo "  --branch-da BRANCH                Alias for --branch-data-activation"
    echo "  --db-name NAME                    Database name (default: rtb-trader-dev)"
    echo "  --db-host HOST                    Database host (default: localhost)"
    echo "  --db-user USER                    Database user (default: adgear)"
    echo "  --db-port PORT                    Database port (default: 5432)"
    echo "  --debug                           Enable debug mode"
    echo "  --help                            Show this help message"
    echo "  --language LANGUAGE               TV client language (default: en)"
    echo "  --no-da-refresh                   Skip data activation data refresh"
    echo "  --no-undo-repos-changes           Do not undo changes in repositories after run"
    echo "  --only-da-artifacts               Run only data activation artifacts generation"
    echo "  --only-setup-repos                Only setup repositories, skip other operations"
    echo "  --output PATH                     Output directory path"
    echo "  --ui-mode                         Used when running from UI"
    echo ""
}
