#!/bin/sh


#sed -i -e /puppet/d /etc/hosts
grep "nt-edu-96-40" /etc/hosts >/dev/null

if [ $? -ne 0 ];then
echo "192.168.96.40 nt-edu-96-40">> /etc/hosts
fi

#ping -c 3  www.baidu.com
#if [ $? -ne 0 ];then
#echo "nameserver 114.114.114.114" >/etc/resolv.conf 
#fi

#if [ ! -f /etc/yum.repos.d/CentOS-Base.repo ];then
 
#cp -r /etc/yum.repos.d/old/CentOS-Base.repo /etc/yum.repos.d/
#
#fi


cd /root/files_exp

rpm -qa |grep -v grep |grep puppet-3
if [ $? -ne 0 ];then
	rpm -ivh  puppet-3.8.7-rpm/puppetlabs/*.rpm
	yum install -y virt-what  libselinux 
        rpm  -Uvh  puppet-3.8.7-rpm/*.rpm 
        /usr/bin/puppet agent  -t  --server  nt-edu-96-40
else
	/usr/bin/puppet agent  -t  --server  nt-edu-96-40

fi
