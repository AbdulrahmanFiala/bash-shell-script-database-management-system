#!/bin/bash
for file in "$(pwd)"/*; do
    if [ -f "$file" ]; then
        # Your code to process each file goes here
        tr -d '\r' <"$file" >temp_script.sh && mv temp_script.sh "$file"
        echo "Processing file: $file"
        sudo chmod 777 "$file"
    elif [ "$file" == "$(pwd)/.git" ]; then
        continue
    else
        cd "$file"
        ./../carriage_returns.sh
    fi
done
