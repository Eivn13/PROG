#!/bin/bash

declare -i time	#signaling that time will be integer
declare -i currSec
declare -i reborn

if [ "$#" != 1 ]	
then
    echo "Zadajte vstupny argument v sekundach"
    exit 2
fi

arg=$1	#save first arg to arg variable
> tmp.txt #save nothing in tmp, making it as "new"

ps -aux | tail -n+2 > tmp.txt	# save every line except first two

if [ $USER != "root" ]	#check whether user is root
then
    cat tmp.txt | grep "$USER" > procesy.txt	#if not, send only $USER processes
else
    cat tmp.txt > procesy.txt	#send everything
fi

array_maker=`cat procesy.txt | awk '{print $2}'` #save second column to PID
PID=(`echo ${array_maker}`)
array_maker=`cat procesy.txt | awk '{print $1}'` #first to OWNER
OWNER=(`echo ${array_maker}`)
array_maker=`cat procesy.txt | awk '{print $11}'` #eleventh to PATH
PATH=(`echo ${array_maker}`)
#printf '%s\n' "${OWNER[@]}"

printf "Naslo sa ${#PATH[@]} procesov\n"
printf "%-20s %-30s %-20s %-50s \n" "PID procesu:" "Cas spustenia procesu [s]:" "Vlastnik:" "Cesta k spustenemu suboru:"

num=0	#variable that holds numOfLine
for i in ${PATH[@]}; do
    if [ -e $i ]; #does dir exists? if yes, then..
    then
        currSec=$(date +%s) #get date from 1970 in seconds
        reborn=$(stat -c %Y /proc/2400)	#get date from last update
        
        time=$(($currSec - $reborn)) #subtract currDate and last update to get lifetime
        if (( "$time" < "$arg" )); #we only want processes younger than time
        then
            output=`(ls -l $i | grep -w "exe \->" | awk '{print $11}') 2> /dev/null` #get path to exe of process
            echo $output            
            if [[ $output != "/usr/bin/sudo" ]] && [[ $output != "/bin/bash" ]] && [[ ! -z $output ]]; then #filter sudo/bash or without path
                printf "%-20s %-30s %-20s %-50s \n" "$i" "$time" "${OWNER[$num]}" "$output"
            fi
        fi
    fi
    num=$((num + 1))
done
exit 0
