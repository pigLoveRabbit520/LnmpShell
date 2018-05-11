# LNMP编译脚本
Linux 上php mysql nginx集成bash脚本[下载](http://ongd1spyv.bkt.clouddn.com/LNMP.tar.gz)

# 使用
```
chmod a+x install.sh
./install.sh
```

# 注意
* 必须以root用户运行脚本
* `install.sh`用来安装nginx和php，`mysql.sh`用来安装mysql
* 修改php和nginx版本的话，请修改`nginx_version`和`php_version`变量（在shell开头）
* php7.2以上请除去安装mcrypt部分（安装libmcrypt，mhash，mcrypt）

# 代码说明
1. `Get_Dist_Name`用来判断不同的Linux发行版
2. `install_dependencies`安装软件依赖
3. `install_nginx`安装nginx
4. `install_php`安装php


# 联系
我的[博客](http://51nazi.com/ "nazi")
