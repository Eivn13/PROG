#!/bin/bash

> aloha.txt
ip=$(ifconfig | grep "inet addr:" | cut -d ":" -f2 | cut -d " " -f1 | head -1)
echo "IPv4 addr NIC: $ip" >> aloha.txt

gw=$(route | grep "default" | awk '{print $2}')
echo "IPv4 default gateway: $gw" >> aloha.txt

mask=$(ifconfig | grep "Mask" | cut -d ":" -f4 | head -1)
echo "Network mask: $mask" >> aloha.txt

dnses=$(cat /etc/resolv.conf | grep "nameserver" | awk /' / { print $2 }') #write out file resolv.conf, get lines with nameserver in it, awk out second column aka ip addr
read -a arr <<< $dnses #send variable to read command and make array, one line, one element in array
output="";
for i in "${!arr[@]}" #travel through array
do
    output="$output DNS address num$i: "${arr[$i]}","
done
echo ${output::-1}  >> aloha.txt

hddSize=$(df -H | grep /dev/sda1 | awk '{print $2}') #df -H prints sizes in powers of 1000
hddSize=${hddSize::-1} #delete last character
echo "Capacity of hdd: $hddSize GB" >> aloha.txt

freespace=$(df -h / | grep dev | awk '{print $4}') #df -h prints sizes in powers of 1024
echo "Free space on / partition: ${freespace::-1} GiB" >> aloha.txt

awk '/MemTotal/ {print "Total RAM: " $2/1024 " MiB"}' /proc/meminfo   >> aloha.txt #call /proc/meminfo find line with MemTotal, then find second column and divide by 1024 to get MiB
free | awk '/Mem/ {print "Usage of RAM: " $3/$2 * 100.0 "%"}'  >> aloha.txt #call command free, find line with Mem, divide column 3 with column 2 and multiply by 100.0
uname -r | awk '//{print "Version of kernel: " $1 }'  >> aloha.txt
cat /etc/os-release | grep "PRETTY_NAME" | cut -d "\"" -f2 | awk '//{print "Type of distribution and version: " $1 " " $2 " " $3}' >> aloha.txt #find line with PRETTY_NAME, cut line on " and choose second substring, then print column 1 2 and 3
cat aloha.txt
