#!/usr/bin/bash
readarray -t list_of_databases < <(ls "$(pwd)/MyDBs")
PS3="Which database do you want to connect to: "

select db in "${list_of_databases[@]}"; do
    if [[ "$REPLY" =~ ^[0-9]+$ && "$REPLY" -ge 1 && "$REPLY" -le ${#list_of_databases[@]} ]]; then

        cd "$(pwd)/MyDBs/$db"
        PS3="Select an operating on the database $db: "
        options=("Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to the main menue")

        select choice in "${options[@]}"; do
            case $choice in
            "Create Table")
                "../../scripts/create_table.sh"
                break
                ;;
            "List Tables")
                "../../scripts/list_tables.sh"
                break
                ;;
            "Drop Table")
                "../../scripts/drop_table.sh"
                break
                ;;
            "Insert into Table")
                "../../scripts/insert_into_table.sh"
                break
                ;;
            "Select From Table")
                "../../scripts/select_from_table.sh"
                break
                ;;
            "Delete From Table")
                "../../scripts/delete_record.sh"
                break
                ;;
            "Update Table")
                "../../scripts/update_table.sh"
                break
                ;;
            "Back to the main menue")
                "../../opening_menu.sh"
                break
                ;;
            *)
                echo "$REPLY" is not one of the choices.
                ;;
            esac
        done

    else
        echo "$DB_NAME Database doesn't exist"
    fi
done
