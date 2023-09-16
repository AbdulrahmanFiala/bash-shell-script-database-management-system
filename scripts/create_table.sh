#!/usr/bin/bash
read -r -p "What is the name of the table: " TABLE_NAME
touch "$(pwd)/$TABLE_NAME"
PRIMARY_KEY=false

read -r -p "How many columns you want? " NO_OF_COLUMNS
for ((i = 1; i <= NO_OF_COLUMNS; i++)); do
    read -r -p "What is the name of column number $i:  " column
    read -r -p "What is the datatype of this column: " datatype

    if [ $i -eq 1 ]; then
        echo "$column   $datatype   ⋮" >"$(pwd)/$TABLE_NAME"

    elif [[ $i = "$NO_OF_COLUMNS" ]]; then
        sed -i "s/$/    $column   $datatype/" "$(pwd)/$TABLE_NAME"
    else
        sed -i "s/$/    $column   $datatype    ⋮/" "$(pwd)/$TABLE_NAME"
    fi
done

if [ "$PRIMARY_KEY" = 'false' ]; then
    PRIMARY_KEY=true
    read -r -p "Which column do you want to be your primary key: " number

    awk -i inplace -F'⋮' -v OFS='⋮' -v col="$number" '{ $col = $col "   (PRIMARY KEY) " }1' "$(pwd)/$TABLE_NAME"
fi
