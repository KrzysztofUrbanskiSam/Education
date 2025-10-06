PROJECTS_ROOT="/home/k.urbanski/Projects"
readarray -t REPOS < <(find ${PROJECTS_ROOT} -name .git -type d -printf "%h\n")

logs_date=$(date +%Y_%m)
logs_out="${HOME}/AuthorRights/${logs_date}"
mkdir -p ${logs_out}

for repo in ${REPOS[@]}; do
    cd $repo
    repo_name=$(basename $(git rev-parse --show-toplevel))
    out_file="${logs_out}/${repo_name}_git.log"
    git log --since="$(date +01.%m.%Y)" --author="$(whoami)" -p --all --unified=0 > $out_file

    if [ ! -s ${out_file} ]; then
        echo "Removing empty log from: ${repo}"
        rm -f ${out_file}
    fi
done

cd ${logs_out} && zip -r ${logs_out}/${logs_date}.zip ${logs_out}/* &> /dev/null
echo "Logs saved to: ${logs_out}"
ls -l $logs_out