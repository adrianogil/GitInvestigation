# !/bin/sh

text_data_file='data_investigation'

function get_text()
{
    sed -n ${1},${2}p ${text_data_file}
}

days=$(git log --pretty=oneline | wc -l)
max_days=5
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
                # echo $result_day_text
 
                current_day_value=$($git_files_cmd HEAD~$d)
                current_day_value=$(echo $current_day_value | awk '{$1=$1;print}')
                # echo $current_day_value

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
