#!/bin/bash
#EXECUTE WITH bash xxx.sh
> ipcky.txt #reset data holder

myAdapter=$(ifconfig | head -9 | grep "inet addr:" | cut -d ":" -f 2 | cut -d " " -f 1) #get ip
ping_out=$(ping -c 3 $myAdapter)
if [ $? = 0 ]
then
    echo "Machine is online"
else
    echo "Machine is offline"
fi

gateWay=$(route | awk /'default/ { print $2 }')
gw_ping_out=$(ping -c 3 $gateWay)
if [ $? = 0 ]
then
    echo "Gateway is online"
else
    echo "Gateway is offline"
fi

dnses=$(cat /etc/resolv.conf | grep "nameserver" | awk /' / { print $2 }')
read -a arr <<< $dnses
for i in "${arr[@]}"
do
    dns=$(ping -c3 "${arr[@]}")
    if [ $? = 0 ]
    then
        echo "Dns server: "${arr[@]}" is online"
    else
        echo "Dns server: "${arr[@]}" is offline"
    fi
done

google=$(nslookup google.com | grep 'Address: ' | awk '{ print $2}')
googleAvail=$(ping -c3 $google)
if [ $? = 0 ]
then
    echo "Google is online"
else
    echo "Google is down"
fi

echo "Script duration: $SECONDS sec"
