#!/bin/bash


cd ./MyDBs/$database/ 2> /dev/null
echo "Enter Table Name:"
read table 2> /dev/null
#print table header
awk 'BEGIN{FS="⋮"}{if (NR==1) {for(i=1;i<=NF;i++){printf "----||----"$i}{print "---|"}}}' $table
echo "Enter Column name: "
read field 2> /dev/null
#get field Number
fieldNumber=$(awk 'BEGIN{FS="⋮"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $table )
if [[ $fieldNumber == "" ]]
then
    echo "Not Found"
    . ../connect.sh
else
    echo "Enter Value:"
    read value 2> /dev/null
    #if the field number = user value store field number in result
    result=$(awk 'BEGIN{FS="⋮"}{if ($'$fieldNumber'=="'$value'") print $'$fieldNumber'}' $table 2>> /dev/null)
    if [[ $result == "" ]]
    then
    echo "Value Not Found"
    . ../connect.sh
    else
        echo "Enter new Value to set:"
        read newValue 2>> /dev/null
        NR=$(awk 'BEGIN{FS="⋮"}{if ($'$fieldNumber' == "'$value'") print NR}' $table 2>> /dev/null)
        echo $recordNumber
        oldValue=$(awk 'BEGIN{FS="⋮"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$fieldNumber') print $i}}}' $table 2>> /dev/null)
        echo $oldValue
        #substitute globally the oldvalue with the newvalue
        sed -i ''$NR's/'$oldValue'/'$newValue'/g' $table 2>> /dev/null
        echo "Row Updated Successfully"
        . ../connect.sh
    fi
fi
cd ../..
../connect.sh