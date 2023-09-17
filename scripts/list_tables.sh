#!/bin/bash
echo "These are the tables that exist in $DB_NAME database: $(ls "$(pwd)")"

echo "Getting back to connect DBs menue"
cd "../../"
"./connect.sh"
