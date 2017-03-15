wget http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz   
tar -xzvf cmake-2.8.10.2.tar.gz   
cd cmake-2.8.10.2   
./bootstrap
make && make install 


group add mysql
useradd -r -g  mysql mysql

mkdir -p /usr/local/mysql


cd mysql-5.6.29

cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1




