#!/bin/bash

# convert the list of tables files of the DB to an array to iterate over them.
readarray -t list_of_tables < <(ls "$(pwd)")

PS3="Which table do you want to delete from: "

# menue to select which table to select from
select option in "${list_of_tables[@]}"; do

    # validate the user input to be a number that's greater than or equal 1 and less than or equal the length of the array
    if [[ "$REPLY" =~ ^[0-9]+$ && "$REPLY" -ge 1 && "$REPLY" -le ${#list_of_tables[@]} ]]; then

        # check if the table is empty
        if [ ! -s "$(pwd)"/"$option" ]; then
            echo "$option" table is an empty table. You cannont delete from an empty table.

        else
            {
                table_lines=()
                starting_line=3
                while IFS= read -r line; do
                    table_lines+=("$line")
                    starting_line=$((starting_line + 1))
                done < <(tail -n +$starting_line "$(pwd)"/"$option")

                PS3="Which line do you want to delete: "

                # select menue displays all the lines of the choosen table
                select choice in "${table_lines[@]}"; do
                    # validate the user input to be a number that's greater than or equal 1 and less than or equal the length of the array
                    if [[ $REPLY =~ ^[0-9]+$ && $REPLY -ge 1 && $REPLY -le ${#table_lines[@]} ]]; then
                        # substracting 1 from the reply to match the array index that starts from zero
                        selected_line="${table_lines[$((REPLY - 1))]}"
                        # adding 2 to the REPLY to make the first choice matches the the first rec
                        sed -i "$((REPLY + 2)) d" "$(pwd)"/"$option"
                        echo "The following line has been deleted: $selected_line"
                        break
                    else
                        echo "Invalid selection. Please enter a valid number."
                    fi
                done
                break
            }
        fi
    else
        echo "Invalid choice. Please select a valid option."
    fi
done
echo "Getting back to connect DBs menue"
cd "../../"
"./connect.sh"
