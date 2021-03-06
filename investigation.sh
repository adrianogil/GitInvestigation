# !/bin/sh

investigation_dir=$(dirname $0)

text_data_file=${investigation_dir}"/data_investigation"

function get_text()
{
    sed -n ${1},${2}p ${text_data_file}
}

function create_investigation_files()
{
    number_files=$(get_text 23 23)
    file_name_lines=$(get_text 24 24)
    content_index_lines=$(get_text 25 25)

    for i in `seq 1 ${number_files}`;
        do
            cur_line=$(echo $file_name_lines | cut -d \, -f ${i})
            content_line=$(echo $content_index_lines | cut -d \, -f ${i})
            content_line_start=$(echo $(get_text $content_line $content_line) | cut -d \, -f 1)
            content_line_end=$(echo $(get_text $content_line $content_line) | cut -d \, -f 2)
            # echo $cur_line
            file_name=$(get_text $cur_line $cur_line)
            echo -e $(get_text $content_line_start $content_line_end) > $file_name
        done
}

# Verify if is inside a git repo
function verify_git_repo()
{
    inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

    if [ "$inside_git_repo" ]; then
      has_commits="$(git log 2>/dev/null)"
      if [ "$has_commits" ]; then
        echo $(get_text 22 22)
        howmany_commits="$(git log --pretty=oneline | wc -l)"
        echo ${howmany_commits}
      else
        # Day 0
        echo $(get_text 21 21)
        echo
        echo -e $(get_text 38 43)
        create_investigation_files
        exit 0
      fi

    else
      echo $(get_text 13 13)
      exit 0
    fi
}

# Git investigation label
printf "\n\n$(get_text 14 19)\n\n"

verify_git_repo

echo 'Test'

days=$(git log --pretty=oneline | wc -l)
max_days=2
let "verify_days=${max_days} - 1"

echo ${days}$(get_text 1 1)

function verify_investigation()
{
    echo 'Verifying results...'

    git_files_cmd='git diff-tree --no-commit-id --name-status -r '

    result_lines=$(get_text 4 4)

    for i in `seq 1 ${verify_days}`;
        do
                let "d=${i} - 1"
                echo 'Verify day '$d

                cur_line=$(echo $result_lines | cut -d \, -f ${i})
                # echo $cur_line
                cur_line=$(get_text $cur_line $cur_line)
                # echo $cur_line
                cur_line_1=$(echo $cur_line | cut -d \, -f 1)
                cur_line_2=$(echo $cur_line | cut -d \, -f 2)
                result_day_text=$(get_text $cur_line_1 $cur_line_2)
                result_day_text=$(echo $result_day_text | xargs)
                echo $result_day_text

                current_day_value=$($git_files_cmd HEAD~$d)
                current_day_value=$(echo $current_day_value | xargs)
                echo $current_day_value

                if [ "$current_day_value" == "$result_day_text" ]; then
                    echo 'Correct result for day '$d
                else
                    echo 'Wrong result for day '$d
                fi
        done
}

if [ "$days" -eq "$max_days" ]; then
    echo $(get_text 2 2)
    verify_investigation
elif [ "$days" -gt "$max_days" ]; then
    echo $(get_text 3 3)
else
    let "remain_days=${max_days} - ${days}"
    echo "You didn't finish your investigation. You should run "${max_days}" days of investigation"
    echo "(That means you need more "${remain_days}" days)"
fi
