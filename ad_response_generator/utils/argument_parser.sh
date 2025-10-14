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
                shift; AD_LANGUAGE="$1"; shift ;;
            --no-da-refresh)
                REFRESH_DA_DATA=false; shift ;;
            --ui-mode)
                UI_MODE=true; shift ;;
            --debug)
                DEBUG=true; shift ;;
            --output)
                shift; OUTPUT="$1"; shift ;;
            *)
                echo "WARNING: Ignoring unknown option: $1"; shift ;;
        esac
    done
}

function show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --creatives-ids id1 id2 ...   List of creative IDs"
    echo "  --branch-bidder BRANCH        Bidder branch name (default: main)"
    echo "  --branch-data-activation BRANCH  Data activation branch name (default: master)"
    echo "  --db-name NAME                 Database name (default: rtb-trader-dev)"
    echo "  --db-host HOST                 Database host (default: localhost)"
    echo "  --db-user USER                 Database user (default: adgear)"
    echo "  --db-port PORT                 Database port (default: 5432)"
    echo "  --no-da-refresh                Skip data activation data refresh"
    echo "  --debug                        Enable debug mode"
    echo "  --output PATH                  Output directory path"
    echo "  --help                         Show this help message"
    echo ""
}
