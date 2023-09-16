#!/usr/bin/bash
read -r -p "What's the name of the table that you want to drop? " DROPPED_TABLE

if [ -e "$(pwd)"/"$DROPPED_TABLE" ]; then
    rm "$(pwd)"/"$DROPPED_TABLE"
    echo "$DROPPED_TABLE" table has been dropped successfully
else
    echo "$DROPPED_TABLE" does not exist as a table in the database
fi
