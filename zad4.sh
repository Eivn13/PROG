#!/bin/bash
#EXECUTE WITH bash xxx.sh


myAdapter=$(ifconfig | head -9 | grep "inet addr:" | cut -d ":" -f 2 | cut -d " " -f 1) #get ip from ifconfig, cut string on : and then choose second substring, then cut on whitespace and get first substring
ping_out=$(ping -c 3 $myAdapter) #ping myadapter ip with 3 packets
if [ $? = 0 ]   #if result from last command was 0
then
    echo "Machine is online"
else
    echo "Machine is offline"
fi

gateWay=$(route | awk /'default/ { print $2 }') #call route, then get line with default and get second column
gw_ping_out=$(ping -c 3 $gateWay) #ping gateway with 3 packets, im saving output to suppress it
if [ $? = 0 ]
then
    echo "Gateway is online"
else
    echo "Gateway is offline"
fi

dnses=$(cat /etc/resolv.conf | grep "nameserver" | awk /' / { print $2 }') #write out file resolv.conf, get lines with nameserver in it, awk out second column aka ip addr
read -a arr <<< $dnses #send variable to read command and make array, one line, one element in array
for i in "${arr[@]}" #travel through array
do
    dns=$(ping -c3 "${arr[@]}") #ping, saving to var to suppress
    if [ $? = 0 ]
    then
        echo "Dns server: "${arr[@]}" is online" # outputting ip of DNS, because there might be more than one #clarity
    else
        echo "Dns server: "${arr[@]}" is offline"
    fi
done

google=$(nslookup google.com | grep 'Address: ' | awk '{ print $2}') #get network info from domain name, get line with address, get second "column"
googleAvail=$(ping -c3 $google)
if [ $? = 0 ]
then
    echo "Google is online"
else
    echo "Google is down"
fi

echo "Script duration: $SECONDS sec" #output runtime of script
