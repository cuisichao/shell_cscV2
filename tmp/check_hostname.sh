#!/bin/sh

if [ -e /etc/init.d/had_hostname.conf ]; then
echo "Had set hostname, abort!"
else

HOST_IP=`/sbin/ifconfig | grep 'inet addr' | head -n 1 | awk '{print $2}' | awk -F ':' '{print $2}'`
echo "IP: "$HOST_IP

if [ "$HOST_IP" != "127.0.0.1" ]; then

IP3=`echo $HOST_IP | awk -F '.' '{print $3}'`
IP4=`echo $HOST_IP | awk -F '.' '{print $4}'`
HOST_NAME="hzyh-edu-"$IP3"-"$IP4
echo "hostname: "$HOST_NAME

/bin/hostname $HOST_NAME
sed -i -e "s/HOSTNAME=.*/HOSTNAME=$HOST_NAME/g"  /etc/sysconfig/network

echo $HOST_IP"  "$HOST_NAME >> /etc/hosts

date > /etc/init.d/had_hostname.conf

fi
fi

