#!/bin/bash
# convert the list of tables files of the DB to an array to iterate over them.
readarray -t list_of_tables < <(ls "$(pwd)")

PS3="Which table do you want to select from: "

# menue to select which table to select from
select option in "${list_of_tables[@]}"; do
    # validate the user input to be a number that's greater than or equal 1 and less than or equal the length of the array
    if [[ "$REPLY" =~ ^[0-9]+$ && "$REPLY" -ge 1 && "$REPLY" -le ${#list_of_tables[@]} ]]; then

        # check if the table is empty
        if [ ! -s "$(pwd)"/"$option" ]; then
            echo "$option" table is an empty table. You cannont select from an empty table.

        else
            {
                PS3="Do you want to select the whole file or only a row: "

                # menue to choose whether to select the whole file or only a row
                select choice in "Whole File" "Only a row"; do
                    case "$choice" in
                    "Whole File")
                        cat "$(pwd)"/"$option"
                        break
                        ;;
                    "Only a row")
                        read -r -p "Please enter the row number you want to read: " row_number

                        # validate that the user input is a vaild row in the chosen table
                        while [ "$row_number" -gt "$(wc -l <"$(pwd)"/"$option")" ]; do
                            read -r -p "Please enter a vaild row number: " row_number
                        done

                        # print the choosen row number
                        sed -n "${row_number}p" "$(pwd)"/"$option"

                        break
                        ;;
                    *)
                        echo "Invalid choice, please select a valid option."
                        ;;
                    esac
                done

                break
            }
        fi
    else
        echo "Invalid choice. Please select a valid option."
    fi
done
