#!/bin/sh

# linux上nginx，php，mysql集成环境
# Author salamander

basepath=$(cd `dirname $0`; pwd)

# 1. nginx安装

yum install -y gcc gcc-c++

# pcre安装
tar -zxvf pcre-8.40.tar.gz
cd ./pcre-8.40
./configure --prefix=/usr/local/pcre-8.40
make
make install

cd $basepath

# zlib安装
tar -zxvf zlib-1.2.11.tar.gz
cd ./zlib-1.2.11
./configure --prefix=/usr/local/zlib-1.2.11
make
make install

cd $basepath

# openssl安装，注意openssl是./config
tar -zxvf openssl-1.1.0e.tar.gz
cd ./openssl-1.1.0e
./config  
make
make install

cd $basepath

# nginx安装 注意 --with-pcre=  --with-zlib  指的是源码路径
tar -zxvf nginx-1.10.3.tar.gz
cd ./nginx-1.10.3
./configure --prefix=/usr/local/nginx-1.10.3 --with-pcre=./../pcre-8.40  --with-zlib=./../zlib-1.2.11
make
make install

echo 'Nginx installed successfully!'


