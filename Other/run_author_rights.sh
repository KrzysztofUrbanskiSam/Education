REPOS=(
    "/home/k.urbanski/Projects/data-activation-dags"
    "/home/k.urbanski/Projects/data-activation-producer-wrapper"
    "/home/k.urbanski/Projects/dsp-lds"
    "/home/k.urbanski/Projects/Education"
    "/home/k.urbanski/Projects/rtb-bidder"
    "/home/k.urbanski/Projects/rtb-trader")

logs_date=$(date +%Y_%m)
logs_out="${HOME}/AuthorRights/${logs_date}"
mkdir -p ${logs_out}

for repo in ${REPOS[@]}; do
    cd $repo
    repo_name=$(basename $(git rev-parse --show-toplevel))
    out_file="${logs_out}/${repo_name}_git.log"
    git log --since="$(date +01.%m.%Y)" --author="$(whoami)" -p --all --unified=0 > $out_file

    if [ ! -s ${out_file} ]; then
        echo "Log from ${repo} is empty. Removing"
        rm -f ${out_file}
    fi
done

cd ${logs_out} && zip -r ${logs_out}/${logs_date}.zip ${logs_out}/* &> /dev/null
ls -l $logs_out