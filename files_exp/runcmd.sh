#!/bin/bash
cd ~/files_exp
#################################

### 校验虚拟机时间同步机制
check_ntp(){

chkconfig  ntpd off
/etc/init.d/ntpd stop
grep '192.168.20.201' /var/spool/cron/root >/dev/null
if [ $? -eq 0 ];then
crontab -l 
else
echo '0 * * * * /usr/sbin/ntpdate  192.168.20.201' >> /var/spool/cron/root
crontab -l 
fi

grep '/usr/sbin/ntpdate' /etc/rc.local >/dev/null
if [ $? -eq 0 ];then
grep '/usr/sbin/ntpdate' /etc/rc.local
else
echo '/usr/sbin/ntpdate  192.168.20.201' >> /etc/rc.local 
grep '/usr/sbin/ntpdate' /etc/rc.local
fi 

echo -e "\n\n"
date
echo  -e "\n\n"
}

#check_ntp
#sh ./restart_cloudstack.sh check
free -m
