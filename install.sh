#!/bin/bash

# linux上nginx，php，mysql集成环境
# Author salamander

set -e # "Exit immediately if a simple command exits with a non-zero status."
basepath=$(cd `dirname $0`; pwd)
DISTRO=''
PM=''
nginx_version='1.10.3'
php_version='7.1.16'
pcre_version='8.38'
zlib_version='1.2.11'
libmcrypt_version='2.5.8'
mhash_version='0.9.9.9'
mcrypt_version='2.6.8'

Get_Dist_Name()
{
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    echo "Your Linux Distribution is ${DISTRO}";
}

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

Get_Dist_Name

if [[ $DISTRO == 'CentOS' || $DISTRO == 'RHEL' || $DISTRO == 'Fedora' ]]; then
    yum install -y gcc gcc-c++
    yum install -y libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel mysql-devel
elif [[ $DISTRO == 'Debian' || $DISTRO == 'Ubuntu' ]]; then
    apt-get install -y gcc g++ openssl libssl-dev  libcurl4-openssl-dev \
    libxml2 libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev default-libmysqlclient-dev
fi



# 1. nginx安装
wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
wget https://svwh.dl.sourceforge.net/project/pcre/pcre/${pcre_version}/pcre-${pcre_version}.tar.gz
wget https://zlib.net/zlib-${zlib_version}.tar.gz
tar -zxvf nginx-${nginx_version}.tar.gz 
tar -zxf pcre-${pcre_version}.tar.gz
tar -zxf zlib-${zlib_version}.tar.gz


# nginx安装 注意 --with-pcre=  --with-zlib --with-openssl  指的是源码路径
cd ./nginx-${nginx_version}
./configure --prefix=/usr/local/nginx-${nginx_version} --with-pcre=./../pcre-${pcre_version}  --with-zlib=./../zlib-${zlib_version} --with-http_stub_status_module \
--with-http_ssl_module
make
make install


echo 'Nginx installed successfully!'


# 2. php安装 php 7.1以下支持mcrypt
cd $basepath

# 安装libmcrypt库
wget https://cfhcable.dl.sourceforge.net/project/mcrypt/Libmcrypt/${libmcrypt_version}/libmcrypt-${libmcrypt_version}.tar.gz
tar zxvf libmcrypt-${libmcrypt_version}.tar.gz
cd libmcrypt-${libmcrypt_version}
./configure
make
make install

cd $basepath

# 安装mhash库
wget https://versaweb.dl.sourceforge.net/project/mhash/mhash/${mhash_version}/mhash-${mhash_version}.tar.gz
tar zxvf mhash-${mhash_version}.tar.gz
cd mhash-${mhash_version}
./configure
make
make install

cd $basepath

# 安装mcrypt库
wget https://astuteinternet.dl.sourceforge.net/project/mcrypt/MCrypt/${mcrypt_version}/mcrypt-${mcrypt_version}.tar.gz
tar -zxvf mcrypt-${mcrypt_version}.tar.gz
cd mcrypt-${mcrypt_version}
export LD_LIBRARY_PATH=/usr/local/lib
./configure
make
make install



cd $basepath

tar -zxvf php-${php_version}.tar.gz
cd ./php-${php_version}


./configure \
--prefix=/usr/local/php7 \
--with-config-file-path=/usr/local/php7/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysqli \
--with-pdo-mysql \
--with-libdir=lib64 \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath  \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--disable-fileinfo \
--enable-maintainer-zts

make 
make install

# create a link to php
ln -s /usr/local/php7/bin/php /usr/local/bin/

# write php-fpm configure
cat > /usr/local/php7/etc/php-fpm.conf <<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 60
pm.start_servers = 30
pm.min_spare_servers = 30
pm.max_spare_servers = 60
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log

EOF

echo 'PHP installed successfully!'
