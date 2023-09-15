#!/usr/bin/bash
read -r -p "What's the name of the Database that you want to connect to " DB_NAME

DB_PATH="/home/MyDBs/$DB_NAME"

if [ -d "$DB_PATH" ]; then
    cd "$DB_PATH"
    PS3="Select an option: "
    options=("Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table")

    select choice in "${options[@]}"; do
        case $choice in
        "Create Table")
            /home/commands/creat_table.sh
            break
            ;;
        "List Tables")
            /home/commands/list_tables.sh
            break
            ;;
        "Drop Table")
            /home/commands/drop_tables.sh
            break
            ;;
        "Insert into Table")
            /home/commands/insert_into_table.sh
            break
            ;;
        "Select From Table")
            /home/commands/select_from_table.sh
            break
            ;;
        "Delete From Table")
            /home/commands/delete_from_table.sh
            break
            ;;
        "Update Table")
            /home/commands/update_table.sh
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