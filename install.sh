#!/bin/sh

# linux上nginx，php，mysql集成环境
# Author salamander

set -e # "Exit immediately if a simple command exits with a non-zero status."
basepath=$(cd `dirname $0`; pwd)

# 1. nginx安装

yum install -y gcc gcc-c++

tar -zxf nginx-1.10.1.tar.gz 
tar -zxf pcre-8.38.tar.gz
tar -zxf zlib-1.2.11.tar.gz
tar -zxf openssl-1.1.0e.tar.gz



# nginx安装 注意 --with-pcre=  --with-zlib --with-openssl  指的是源码路径
cd ./nginx-1.10.1
./configure --prefix=/usr/local/nginx-1.10.1 --with-pcre=./../pcre-8.38  --with-zlib=./../zlib-1.2.11  --with-openssl=./../openssl-1.1.0e
make
make install


echo 'Nginx installed successfully!'
