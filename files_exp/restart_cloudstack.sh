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

#### 判断状态是否正常
HECK_RUN()
{
if [ "$?" = "0" ]; then
  echo "=============== Run [$1] succeed! ==============="
  sleep 3
else
  echo "Error, abort!"
  exit 2
fi 
}


### 挂载 gv_primarymount 共 2 个存储
mount_gfs(){

int_gv0=`df -h |grep "/gv_primarymount$"|wc -l` 
if [ int_gv0  -ne 0 ];then
`cat /etc/rc.local  |grep /gv_primarymount$`
HECK_RUN "mount gv_primarymount"

fi


int_gv1=`df -h |grep "/gv_primarymount1$"|wc -l`
if [ int_gv0  -ne 0 ];then
`cat /etc/rc.local  |grep /gv_primarymount1`
HECK_RUN "mount gv_primarymount1"
fi


}

### 开启 cloudstack-agent 程序
start_agent(){
/etc/init.d/cloudstack-agent  start
}

#检查状态
check_agent(){
echo -e "\n ===== disk usage ====== \n"

df -h
echo -e "\n\n"

/etc/init.d/cloudstack-agent status
echo  -e "\n cloudstack-agent process count is `ps -ef|grep java |wc -l` \n "


}


### 停止 cloudstack-agent 和 umount 卸载存储
stop_agent(){
/etc/init.d/cloudstack-agent stop 

spid=`ps -ef|grep cloudstack-agent|grep -v grep |awk '{print $2}'`

if [ -n "$spid" ]
then
	while [ -n "$spid" ]  
		do
        	sleep 2
		spid=`ps -ef|grep cloudstack-agent|grep -v grep |awk '{print $2}'`
		/etc/init.d/cloudstack-agent stop
		echo "Now stop cloudstack-agent"
		done
else
	echo " stop cloudstack-agent"
fi

umount -l /gv_primarymount
ECK_RUN "umount gv_primarymount"

umount -l /gv_primarymount1
ECK_RUN "umount gv_primarymount1"

}

shutdown_system()
{

echo "==================Now shutdown system ==============="
#init 0 


}

################# 执行方法 ###############
#check_ntp

case "$1" in
stop)
        stop_agent 
        ;;
start)
        mount_gfs
   	start_agent
	;;
check)
	check_agent
	;;

shutdown)
	echo "shutdown system Now"
	shutdown_system	
        ;;
*)
        echo "$0  start|stop|check|shutdown"
        ;;
esac
