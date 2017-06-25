#!/bin/sh

set -e # "Exit immediately if a simple command exits with a non-zero status."
basepath=$(cd `dirname $0`; pwd)

yum install -y gcc gcc-c++ ncurses-devel perl  bison

wget http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz
tar -xzvf cmake-2.8.10.2.tar.gz   
cd cmake-2.8.10.2
./bootstrap
make && make install


groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

MYSQL_DIR="/usr/local/mysql"
MYSQL_DARA_DIR="/usr/local/mysql/data"

mkdir -p  ${MYSQL_DIR}

cd $basepath
tar -zxvf mysql-5.6.29.tar.gz && cd mysql-5.6.29

cmake -DCMAKE_INSTALL_PREFIX=${MYSQL_DIR} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1

make && make install

cd ${MYSQL_DIR}

chown -R mysql:mysql .

cat > /etc/my.cnf <<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = ${MYSQL_DIR}
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
#innodb_data_home_dir = ${MYSQL_DARA_DIR}
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = ${MYSQL_DARA_DIR}
#innodb_buffer_pool_size = 16M
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF


cd ${MYSQL_DIR}  
scripts/mysql_install_db --user=mysql --datadir=${MYSQL_DARA_DIR}  

# add service
cp support-files/mysql.server /etc/init.d/mysql










