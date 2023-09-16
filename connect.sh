#!/usr/bin/bash
read -r -p "What's the name of the Database that you want to connect to: " DB_NAME

DB_PATH="./MyDBs/$DB_NAME"

if [ -d "$DB_PATH" ]; then
    cd "$DB_PATH"
    PS3="Select an option: "
    options=("Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table")
    select choice in "${options[@]}"; do
        case $choice in
        "Create Table")
            "./../../scripts/create_table.sh"
            break
            ;;
        "List Tables")
            "./../../scripts/list_tables.sh"
            break
            ;;
        "Drop Table")
            "./../../scripts/drop_table.sh"
            break
            ;;
        "Insert into Table")
            "./../../scripts/insert_into_table.sh"
            break
            ;;
        "Select From Table")
            "./../../scripts/select_from_table.sh"
            break
            ;;
        "Delete From Table")
            "./../../scripts/delete_from_table.sh"
            break
            ;;
        "Update Table")
            "./../../scripts/update_table.sh"
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
