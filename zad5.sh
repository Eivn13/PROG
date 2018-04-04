#!/bin/bash

ip=$(ifconfig | grep "inet addr:" | cut -d ":" -f2 | cut -d " " -f1 | head -1)
echo "IPv4 addr NIC: $ip"

gw=$(route | grep "default" | awk '{print $2}')
echo "IPv4 default gateway: $gw"

mask=$(ifconfig | grep "Mask" | cut -d ":" -f4 | head -1)
echo "Network mask: $mask"

dnses=$(cat /etc/resolv.conf | grep "nameserver" | awk /' / { print $2 }') #write out file resolv.conf, get lines with nameserver in it, awk out second column aka ip addr
read -a arr <<< $dnses #send variable to read command and make array, one line, one element in array
output="";
for i in "${arr[@]}" #travel through array
do
    output="$output DNS address(es) : "${arr[@]}","
done
echo ${output::-1}

#1GiB = 1.074 GB, need to convert from GiB to GB
hddSize=$(fdisk -l | grep "Disk /dev/sda" | cut -d "," -f1 | cut -d ":" -f2)
hddSize=${hddSize::-3}
answer=$(bc <<< "$hddSize*1.074")
echo "Capacity of hdd: $hddSize GB"

freespace=$(df -h / | grep dev | awk '{print $4}')
echo "Free space on / partition: ${freespace::-1} GB"

awk '/MemTotal/ {print "Total RAM: " $2/1024 " MiB"}' /proc/meminfo
free | awk '/Mem/ {print "Usage of RAM: " $3/$2 * 100.0 "%"}'
uname -r | awk '//{print "Version of kernel: " $1 }'
cat /etc/os-release | grep "PRETTY_NAME" | cut -d "\"" -f2 | awk '//{print "Type of distribution and version: " $1 " " $2 " " $3}'
