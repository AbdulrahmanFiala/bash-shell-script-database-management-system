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
    key=$(awk -F "⋮" -v col="$column_number" 'NR == 1 {print $col}' "$(pwd)/$option" | awk -F "," '{print $3}')

    # check if the column is a primary key
    if [[ $key == *"(PRIMARY_KEY)"* ]]; then
        # populate the previous_values array with the previous values of the same column
        mapfile -t previous_values < <(awk -F "⋮" -v col="$column_number" 'NR > 2 {gsub(/^[ \t]+|[ \t]+$/,"",$col); print $col}' "$(pwd)/$option")

        # iterate over the array to make sure that the updated_value is unique
        for item in "${previous_values[@]}"; do
            while [[ "$item" == "$updated_value" ]]; do
                read -r -p "You can only enter unique values since this column is a primary key. Please enter a different value: " updated_value

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
    while [[ ! "$updated_value" =~ ^[0-9]+$ ]]; do
        read -r -p "Please enter a vaild integer: " updated_value
    done
    primary_key_vaildate
}

function vaildate_string() {
    while [[ ! "$updated_value" =~ ^[a-zA-Z\s]*$ ]]; do
        read -r -p "Please enter a vaild string: " updated_value
    done
    primary_key_vaildate
}

function vaildate_boolean() {
    while [[ ! ("$updated_value" == "true" || "$updated_value" == "false") ]]; do
        read -r -p "Please enter a boolean value in small case: " updated_value
    done
    primary_key_vaildate
}

# populate the list_of_tables array with teh files contained in the current directory
readarray -t list_of_tables < <(ls "$(pwd)")

PS3="Which table do you want to update: "

# menue to select which table to update
select option in "${list_of_tables[@]}"; do

    # validate the user input to be a number that's greater than or equal 1 and less than or equal the length of the array
    if [[ "$REPLY" =~ ^[0-9]+$ && "$REPLY" -ge 1 && "$REPLY" -le ${#list_of_tables[@]} ]]; then
        # check if the table is empty
        first_record=$(sed -n '3p' "$(pwd)/$option")
        if [ ! -s "$(pwd)"/"$option" ]; then
            echo "$option" table is an empty table. You cannont update an empty table.
        elif [ -z "$first_record" ]; then
            echo "$option" table dones not have any records. Please insert into it first before trying to update it.
        else
            {
                # populate the table_lines array with the lines of the chosen table starting from the 3rd line since the first line is the heading and the second is a seprator between the header and the actual data
                table_lines=()
                starting_line=3
                while IFS= read -r line; do
                    table_lines+=("$line")
                    starting_line=$((starting_line + 1))
                done < <(tail -n +$starting_line "$(pwd)"/"$option")

                PS3="Which row/record do you want to update: "
                # select menue displays all the lines of the choosen table
                select choice in "${table_lines[@]}" "Type exit to exit editing"; do
                    # validate the user input to be a number that's greater than or equal 1 and less than or equal the length of the array
                    if [[ $REPLY =~ ^[0-9]+$ && $REPLY -ge 1 && $REPLY -le ${#table_lines[@]} ]]; then

                        # substracting 1 from the reply to match the array index that starts from zero
                        selected_line="${table_lines[$((REPLY - 1))]}"
                        echo "This is the line that you want to update: $selected_line"

                        #count the number of columns/fields in the selected line
                        no_of_columns=$(grep -o "⋮" <<<"$selected_line" | wc -l)
                        read -r -p "Which column do you want to update: " column_number

                        # vaildate the user reply to be a number and less than or equal the number of columns
                        while [[ ! $column_number =~ ^[0-9]+$ || "$column_number" -gt "$no_of_columns" ]]; do
                            read -r -p "Please insert a vaild column number to update since there're only ($no_of_columns columns): " column_number
                        done

                        read -r -p "Please enter the updated value: " updated_value
                        # extract the data type of the field that will be updated
                        data_type=$(awk -F "⋮" -v col="$column_number" 'NR == 1 {print $col}' "$(pwd)/$option" | awk -F "," '{print $2}')

                        # vaildate the user input data_type and primary_key wise
                        if [[ "$data_type" == *'int'* ]]; then
                            vaildate_int

                        elif [[ "$data_type" == *'string'* ]]; then
                            vaildate_string

                        else
                            vaildate_boolean
                        fi

                        # Use awk to update the specific line and column
                        awk -i inplace -v line="$((REPLY + 2))" -v col="$column_number" -v val=" $updated_value" '
                        BEGIN { OFS = "⋮" } 
                        NR == line {
                            split($0, fields, OFS)
                            
                            fields[col] = val
                            
                            for (i = 1; i <= length(fields); i++) {
                                printf "%s", fields[i]
                                if (i < length(fields)) {
                                    printf OFS
                                }
                            }
                            printf "\n"
                            next
                        }
                        { print }
                    ' "$(pwd)/$option"
                        fix_indentation
                        echo "The column has been updated successfully!"
                        echo "Getting back to connect DBs menue"
                        cd "../../"
                        "./connect.sh"

                    else
                        echo "Invalid selection. Please enter a valid number."
                    fi
                done
            }
        fi
    else
        echo "Invalid choice. Please select a valid number."
    fi
done
