if [[ -z "$ad_response_generator_context" ]]; then
    echo "Cannot invoke outside 'ad_response_generator"
    echo "Run 'bash ad_response_generator <args>'"
    exit 1
fi

function perform_transcoding() {
    local creative_id="$1"
    local transcoding_logs="${output_logs}/${creative_id}_transcoding.txt"
            cd ${ROOT_TRADER}
            echo "user = User.find(1)
            ability = Ability.build(user)
            Creatives::AssetsProcessors::StvBanner.new(${creative_id}, user).call
            exit" | rails console &> $transcoding_logs
}

function setup_trader_branch() {
    local repo_branch="$1"

    setup_git_repository "rtb-trader" "${repo_branch}" "https://github.com/adgear/rtb-trader" "ROOT_TRADER"
}
