#!/bin/bash

if [ "$1" == "--help" ] #help
then
    printf "Script for backing up a directory.
Arguments control filename format:
    Arg: -n\tFormat: file_name-MM_HH_DD_MM_YY
    Arg: -d\tFormat: MM_HH_DD_MM_YY-file_name\n"
    exit 0
fi

saveFormat=0
errorCounter=0
input=""
find=""
filename=""

checkIfDir() {
    find=$(find ~ -name "$1" 2>/dev/null) #if find throws error, reroute to black hole
    if [ $(echo $(test -d "$find") $?) -ne 0 ]; then     #test, if the file is a directory and if yes (returns not 0) then...
        echo "Not a directory!"
        let "errorCounter++"

        if [ "$errorCounter" == 3 ]; then
            echo "3 times wrong input detected! The program is shutting down..."
            exit 1 
        fi    
        getInput
    fi
}

getInput() {
    echo "Type in the name of the dir you want to backup with argument [dir -d or dir -n]:"
    read input
    
    parameter=$(echo "$input" | rev | awk '{ print $1}' | rev) #get input, make it read backwards, get first column, make it read backwards again
                                                               #that gives us parameter
    if [ "$parameter" == "-d" ]; then
        saveFormat=1
    elif [ "$parameter" == "-n" ]; then
        saveFormat=2
    else
        echo "Bad parameter!"
        let "errorCounter++"

        if [ "$errorCounter" == 3 ]; then
            echo "3 times wrong input detected! The program is shutting down..."
            exit 1 
        fi    
        getInput
    fi

    filename=$(echo "${input::-3}") #delete last 3 chars
    numberOfLines=$(find ~ -name "$filename" 2>/dev/null | wc -l)

    if [ "$numberOfLines" == 0 ]; then
        echo "File does not exist!"
        let "errorCounter++"
        
        if [ "$errorCounter" == 3 ]; then
            echo "Too many wrong inputs, script will now end."
            exit 1 
        fi    
        getInput
    elif [ "$numberOfLines" == 1 ]; then
        checkIfDir "$filename"
    fi
}

if [ "$saveFormat" == 0 ] #classic input without arguments
then
    getInput

    filename=$(echo "$filename" | sed -e 's/ /_/g') #change every whitespace to _

    if [ "$saveFormat" == 1 ] #if format -> -d
    then
        backupDirectory="$(date +%M"_"%H"_"%d"_"%m"_"%Y)-$filename"

    elif [ "$saveFormat" == 2 ] #if format -> -n
    then
        backupDirectory="$filename-$(date +%M"_"%H"_"%d"_"%m"_"%Y)"
    fi

    mkdir -p ~/backup/  #if dir exists, insert into instead of replacing
    cp -nR "$find" ~/backup/"$backupDirectory"  #do not overwrite and dont follow symbolic links
    printf "Your backup file is stored in ~/backup/$backupDirectory\n"

    
fi

