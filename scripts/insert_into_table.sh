#!/bin/bash
function fix_indentation() {
    max_count=0
    count_of_rows=$(
        wc -l <"$(pwd)/$option"
    )
    no_of_columns=$(awk -v val="⋮" 'NR == 1 {count += gsub(val, val)} END {print count}' "$(pwd)/$option")

    for ((j = 1; j <= "$no_of_columns"; j++)); do
        for ((z = 1; z <= "$count_of_rows"; z++)); do
            if [ $z -eq 2 ]; then
                continue
            fi

            count=$(awk -F'⋮' -v row=$z -v column=$j 'NR==row { print length($column)}' "$(pwd)/$option")
            if [ "$count" -gt "$max_count" ]; then
                max_count=$count
            fi

        done
        for ((i = 1; i <= "$count_of_rows"; i++)); do
            if [ $i -eq 2 ]; then
                continue
            fi
            count=$(awk -F'⋮' -v row=$i -v column=$j 'NR==row { print length($column)}' "$(pwd)/$option")

            result=$((max_count - count))
            white_space=""

            for ((z = 1; z <= "$result"; z++)); do
                white_space="$white_space"" "
            done
            awk -i inplace -F'⋮' -v row=$i -v field=$j -v text="$white_space" '{
        if (NR == row) {
        OFS="⋮"  
        $field = $field text
        }
        print
    }' "$(pwd)/$option"

        done
    done

}

function primary_key_vaildate() {
    key=$(awk -F "⋮" -v col="$i" 'NR == 1 {print $col}' "$(pwd)/$option" | awk -F "," '{print $3}')

    # check if the column is a primary key
    if [[ $key == *"(PRIMARY_KEY)"* ]]; then
        # populate the previous_values array with the previous values of the same column
        mapfile -t previous_values < <(awk -F "⋮" -v col="$i" 'NR > 2 {gsub(/^[ \t]+|[ \t]+$/,"",$col); print $col}' "$(pwd)/$option")

        # iterate over the array to make sure that the data is unique
        for item in "${previous_values[@]}"; do
            while [[ "$item" == "$data" ]]; do
                read -r -p "You can only enter unique values since this column is a primary key. Please enter a different value: " data
                # to validate the user input after entering a unique value
                if [[ "$data_type" == *'int'* ]]; then
                    vaildate_int

                elif [[ "$data_type" == *'string'* ]]; then
                    vaildate_string

                else
                    vaildate_boolean
                fi
            done
        done
    fi
}

function vaildate_int() {
    while [[ ! "$data" =~ ^[0-9]+$ ]]; do
        read -r -p "Please enter a vaild integer: " data
    done
    primary_key_vaildate
}

function vaildate_string() {
    while [[ ! "$data" =~ ^[a-zA-Z\s]*$ ]]; do
        read -r -p "Please enter a vaild string: " data
    done
    primary_key_vaildate
}

function vaildate_boolean() {
    while [[ ! ("$data" == "true" || "$data" == "false") ]]; do
        read -r -p "Please enter a boolean value in small case: " data
    done
    primary_key_vaildate
}

# convert the list of tables files of the DB to an array to iterate over them.
readarray -t list_of_tables < <(ls "$(pwd)")

PS3="Which table do you want to insert into: "

# menue to select which table to select from
select option in "${list_of_tables[@]}"; do
    # validate the user input to be a number that's greater than or equal 1 and less than or equal the length of the array
    if [[ "$REPLY" =~ ^[0-9]+$ && "$REPLY" -ge 1 && "$REPLY" -le ${#list_of_tables[@]} ]]; then
        no_of_columns=$(awk -v val="⋮" 'NR == 1 {count += gsub(val, val)} END {print count}' "$(pwd)/$option")
        echo -e "" >>"$(pwd)/$option"

        for ((i = 1; i <= no_of_columns; i++)); do
            read -r -p "What do you want to insert in column number $i: " data
            data_type=$(awk -F "⋮" -v col="$i" 'NR == 1 {print $col}' "$(pwd)/$option" | awk -F "," '{print $2}')

            if [[ "$data_type" == *'int'* ]]; then
                vaildate_int

            elif [[ "$data_type" == *'string'* ]]; then
                vaildate_string

            else
                vaildate_boolean
            fi

            sed -i '$s/$/'" $data"'⋮/' "$(pwd)/$option"
        done
        fix_indentation
        echo "Getting back to connect DBs menue"
        cd "../../"
        "./connect.sh"
    else
        echo "Invalid choice. Please select a valid option."
    fi
done
