#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then
    echo -e "Script for backing up a directory with cron.\n"
    exit 0
fi

find=""
filename=""

checkIfDir() {
    find=$(find ~ -name "$1")
    echo -e "Your file: " $find
    if [ $(echo $(test -d "$find") $?) -ne 0 ]; then
        echo "Not a directory!"
        let "errorCounter++"

        if [ "$errorCounter" == 1 ]; then
            echo -e "Filename is not a directory! The program is shutting down..."
            exit 1 
        fi
    fi
}

getInput() {
    filename="back up"
    numberOfLines=$(find ~ -name "$filename" | wc -l)

    if [ "$numberOfLines" == 0 ]; then
        echo "Not existing file!"
       
        echo -e "Filename doesnt exist! The program is shutting down..."
        exit 1
    elif [ "$numberOfLines" == 1 ]; then
        checkIfDir "$filename"
    fi
}

getInput
if [ $(echo $(($(date +%s) - $(date +%s -r /home/eivn/PROG/prog/'back up')))) -le 300 ]; then   #if the last modification date of the file was more then 5 minutes
    filename=$(echo "$filename" | sed -e 's/ /_/g') 
    backupDirectory="$(date +%M"_"%H"_"%d"_"%m"_"%Y)-$filename"
    mkdir -p ~/backup_1/
    cp -nR "$find" ~/backup_1/"$backupDirectory"    
fi
