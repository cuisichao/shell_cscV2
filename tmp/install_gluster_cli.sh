#!/bin/bash

#update by csc 20170119

check_umask(){
grep 'umask 0000' /etc/profile >/dev/null
if [ $? -ne 0 ];then
 echo 'umask 0000' >>/etc/profile
 source  /etc/profile
fi


}


mount_gv_cloud(){

check_umask
 mkdir -p /gfs_mnt/data1
/bin/mount -t glusterfs ${1}:/gv_cloud  /gfs_mnt/data1
cat >>/etc/rc.local <<EOF
/bin/mount -t glusterfs ${1}:/gv_cloud  /gfs_mnt/data1
EOF

}

mount_gv_space_uploads(){

check_umask
mkdir -p /space_uploads
mkdir -p  /data0/htdocs/www/eduyun/space/
/bin/mount -t glusterfs ${1}:/gv_uploads  /space_uploads
ln -s /space_uploads   /data0/htdocs/www/eduyun/space/uploads

cat >>/etc/rc.local <<EOF  
/bin/mount -t glusterfs ${1}:/gv_uploads  /space_uploads
EOF

}


mount_gv_aam_uploads(){

check_umask
mkdir -p /aam_uploads
mkdir -p  /home/aamif
/bin/mount -t glusterfs ${1}:/gv_uploads  /aam_uploads
ln -s /aam_uploads  /home/aamif/execelresource
  
cat >>/etc/rc.local <<EOF  
/bin/mount -t glusterfs ${1}:/gv_uploads  /aam_uploads
EOF

}


mount_zhxyjava_uploadfiles(){
check_umask
 mkdir -p /gv_uploadfiles
/bin/mount -t glusterfs ${1}:/gv_uploadfiles  /gv_uploadfiles
cat >>/etc/rc.local <<EOF
/bin/mount -t glusterfs ${1}:/gv_uploadfiles  /gv_uploadfiles
EOF


if [ -d /home/zhxyjava ];then
  if [ ! -d /home/zhxyjava/uploadfiles ];then
  ln -s  /gv_uploadfiles  /home/zhxyjava/uploadfiles
	else 
	echo  "/home/zhxyjava/uploadfiles is already exist! not link! "
  fi
  else
  echo "/home/zhxyjava is not exist! useadd zhxyjava"
fi

}


mount_zhxy_gl_uploadfiles(){
check_umask
 mkdir -p /gv_uploadfiles
/bin/mount -t glusterfs ${1}:/gv_uploadfiles  /gv_uploadfiles
cat >>/etc/rc.local <<EOF
/bin/mount -t glusterfs ${1}:/gv_uploadfiles  /gv_uploadfiles
EOF


if [ -d /home/zhxy_gl ];then
  if [ ! -d /home/zhxy_gl/uploadfiles ];then
  ln -s  /gv_uploadfiles  /home/zhxy_gl/uploadfiles
        else
        echo  "/home/zhxy_gl/uploadfiles is already exist! not link! "
  fi
  else
  echo "/home/zhxy_gl is not exist! useadd zhxyjava"
fi

}


install_glusterfs_3(){

rpm -qa|grep "glusterfs-3." >/dev/null
if [ $? -ne 0 ];then
 rpm  -Uvh  glusterfs-client/*.rpm

 modprobe fuse
 lsmod | grep fuse
 echo  "modprobe fuse" >>/etc/rc.local
  
else
echo  -e "\n  glusterfs3.0 had install ! \n"
fi

}


#######################
gfs_server_ip1="192.168.1.89"
gfs_server_ip2="192.168.1.90"

gfs_server_zhxy_ip1="192.168.1.72"
gfs_server_zhxy_ip2="192.168.1.73"



install_glusterfs_3

#mount_gv_cloud  "${gfs_server_ip1}"
#mount_gv_space_uploads "${gfs_server_ip2}"
#mount_gv_aam_uploads "${gfs_server_ip2}"


####### zhxyjava
#mount_zhxyjava_uploadfiles "${gfs_server_zhxy_ip1}"
#mount_zhxy_gl_uploadfiles "${gfs_server_zhxy_ip2}"


df -h 
echo -e " umask is `umask` \n\n"


