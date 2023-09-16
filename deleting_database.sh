#!/bin/bash

#deleting one of the available databases

read -p "Enter the database name: " DataBaseName


#checking the existence of the database
if ! [[ -d ./MyDBs/$DataBaseName ]]; then
	echo "There is no such name, pelase choose another name"
	. ./deleting_database.sh
else
	rm -r ./MyDBs/"$DataBaseName"
	echo "DataBase: $DataBaseName was deleted Successfully"
fi
	
