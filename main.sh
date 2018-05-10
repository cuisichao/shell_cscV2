#!/bin/bash
version="update  shell  V2.0 by csc 2018-5-5"
echo  "$version"

echo "------------------`date`--------------------" >> error.log




# 检查服务端安装的工具 nmap  sshpass
check_env(){
rpm -qa|grep  nmap >/dev/null 
if [ $? -ne 0 ];then
echo -e "\n Warning --please use  yum install nmap  -y \n"
exit 1
fi



rpm -qa|grep  sshpass >/dev/null
if [ $? -ne 0 ];then
echo -e "\n Warning --please use  yum install  sshpass -y \n"
exit 1
fi

}

#检查 客户端ssh 端口是否正常
check_ssh_status(){
ip=$1
nmap  -p 22 $ip |grep open >/dev/null 
if [ $? -ne 0 ];then
	
	echo "+-------------------------------------------------------------------------------+"
        echo "|Had DONE NO password authorized from local to $ip, This server ssh mybe down ! |."
        echo "|Had DONE NO password authorized from local to $ip| " >> error.log       
	echo "+-------------------------------------------------------------------------------+"

        continue
fi


}

### 核心方法
run_cmd(){
### 密码传递到指定的sshpass 变量 SSHPASS ，可以免密码输入 更安全

export SSHPASS="$2"

### 传输给客户端文件与脚本
echo -e "\n========================> HOST is $1 <=========================\n"
sshpass -e  scp -o StrictHostKeyChecking=no  -r files_exp  root@${1}:.  
if [ $? -eq 0 ];then
echo -e "OK --  scp -r files_exp root@${1} succeed ! \n"
else
echo -e "fail -- scp -r files_exp root@${1} fail !\n"
echo -e "fail -- scp -r files_exp root@${1} fail !\n" >>error.log
fi



####客户端执行脚本
sshpass -e  ssh  -o StrictHostKeyChecking=no  root@${1}  "./files_exp/runcmd.sh "  
if [ $? -eq 0 ];then
echo -e "OK --  ssh  root@${1} ./files_exp/runcmd.sh  succeed ! \n"
else
echo -e "Fail --  ssh  root@${1} ./files_exp/runcmd.sh  fail ! \n"
echo -e "Fail --  ssh  root@${1} ./files_exp/runcmd.sh  fail ! \n" >>error.log
fi


}


##读取配置文件
read_conf(){
cat ip_pass.conf |grep -v ^#|grep -v ^$ |while read line
do
#  echo "cat line is  $line " 
## 获取配置文件的密码  并把密码赋值传到系统变量
  echo $line |grep REMOTE_PASS >/dev/null 

    if [ $? -eq 0 ];then
      export $line   
      continue
    fi

    export REMOTE_IP=`echo $line |awk '{print $1}'`

    ### 获取配置文件IP服务器指定的密码 格式： IP  password
 
    REMOTE_PASS_custom=`echo $line |awk '{print $2}'`
    
    ##传参 给 run_cmd 方法      
    check_ssh_status "$REMOTE_IP"
    
    if [ -n "$REMOTE_PASS_custom" ];then
      run_cmd  "$REMOTE_IP" "$REMOTE_PASS_custom" &
    else
      run_cmd  "$REMOTE_IP" "$REMOTE_PASS" &
    fi

    #sleep 2

done

}


### 告警方法
message(){
  echo "warning -- usage $0 -f ip_pass.conf" 
}



####################### main #################################
if [ ! -f ./ip_pass.conf ];then
  echo "Fail --  ip_pass.conf is not exist !"
  exit 1
fi


if [ ! -e ./files_exp/runcmd.sh ];then
  echo "warnning -- ./files_exp/runcmd.sh is not exist !"
  exit 1
fi


echo ""
grep -n -E 'rm -r|init 0|reboot|shutdown|halt' ./files_exp/*.sh 

if [ $? -eq 0 ];then

  echo -e  "\n \033[32m  Warning --- There are dangerous commands. Please check if they need to be executed \033[0m  \033[31m (Y/N)?  \033[0m\n"
  read RET_SURE
  if [ "$RET_SURE" != "Y" ] && [ "$RET_SURE" != "y" ]; then
	echo "Abort upate!"
	exit;
  fi 
fi




check_env
read_conf


