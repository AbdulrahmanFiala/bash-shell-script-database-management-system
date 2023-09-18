#!/usr/bin/bash
read -r -p "What is the name of the table: " TABLE_NAME
touch "$(pwd)/$TABLE_NAME"
PRIMARY_KEY=false

# ask the user about the number of columns to have
read -r -p "How many columns do you want? " NO_OF_COLUMNS

# vaildate the number of columns
while [[ ! "$NO_OF_COLUMNS" =~ [0-9]+ ]]; do
    read -r -p "Please enter a vaild number: " NO_OF_COLUMNS
done

# iterating for amount equal to the number of columns entered by the user
for ((i = 1; i <= NO_OF_COLUMNS; i++)); do

    # ask the user about the name of the columns
    read -r -p "What is the name of column number $i:  " column

    # vaildate the column name
    while [[ "$column" = "int" || "$column" = "string" || "$column" = "boolean" || "$column" =~ [,⋮] || "$column" =~ ^[0-9] ]]; do
        read -r -p "Please enter a valid column name: " column
    done

    # ask the user about the data type of the column
    PS3="What is the datatype of this column: "
    data_types_list=('int' 'string' 'boolean')
    select datatype in "${data_types_list[@]}"; do
        case $datatype in
        "int")
            break
            ;;
        "string")
            break
            ;;
        "boolean")
            break
            ;;
        *)
            echo "$REPLY" is not one of the choices.
            ;;
        esac
    done

    # if the file is empty we add this first column
    if [ $i -eq 1 ]; then
        echo "$column,   $datatype  ⋮" >"$(pwd)/$TABLE_NAME"

    # if the file is not empty we append rest of the columns
    else
        sed -i "s/$/    $column,   $datatype    ⋮/" "$(pwd)/$TABLE_NAME"
    fi
done

# ask the user which column to be the primary key
if [ "$PRIMARY_KEY" = 'false' ]; then
    PRIMARY_KEY=true

    read -r -p "Which column do you want to be your primary key: " number

    # count the number of columns to validate user input
    column_count=$(awk -F ',' 'NR==1 {print NF; exit}' "$(pwd)/$TABLE_NAME")

    while [[ number -ge $column_count ]]; do
        read -r -p "Please enter a valid column number: " number
    done

    awk -i inplace -F'⋮' -v OFS='⋮' -v col="$number" '{ $col = $col ",   (PRIMARY_KEY)  " }1' "$(pwd)/$TABLE_NAME"
fi
echo ".................................................................................................." >>"$(pwd)/$TABLE_NAME"

echo "Getting back to connect DBs menu: "
cd "../../"
"./connect.sh"
