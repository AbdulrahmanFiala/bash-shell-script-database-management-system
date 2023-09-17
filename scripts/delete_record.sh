#!/bin/bash

cd ./MyDBs/$database/ 2> /dev/null
echo "Please enter table name to delete from: "
read table 2> /dev/null
if [[ -f $table ]]
then
        #print table header
        awk 'BEGIN{FS="⋮"}{if (NR==1) {for(i=1;i<=NF;i++){printf "----||----"$i}{print "---|"}}}' $table
        echo  "Enter Column name:"
        read field 2>> /dev/null

        # get the field number
        fieldNumber=$(awk 'BEGIN{FS="⋮"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $table )
        if [[ $fieldNumber == "" ]]
        then
            echo "Not Found"
            . ../connect.sh
        else
            echo "Enter Value:"
            read value 2>> /dev/null
            result=$(awk 'BEGIN{FS="⋮"}{if ($'$fieldNumber'=="'$value'") print $'$fieldNumber'}' $table 2>> /dev/null)

            if [[ $result == "" ]]
            then
                echo "Value Not Found"
                . ../connect.sh
            else
                # get the record number to be deleted
                NR=$(awk 'BEGIN{FS="⋮"}{if ($'$fieldNumber'=="'$value'") print NR}' $table 2>> /dev/null)
                # delete the record
                sed -i ''$NR'd' $table 2>> /dev/null
                echo "Row Deleted Successfully"
                . ../connect.sh
            fi
        fi
else
    echo "Table doesn't exist"
fi
cd ../..
../connect.sh