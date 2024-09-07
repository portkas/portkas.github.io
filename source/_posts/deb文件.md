---
title: .deb文件
categories:
    - Linux
---
dep文件是debian，Ubuntu等Linux发行版的软件安装包
<!-- more -->
# 安装
deb包安装方法有两种：
1.直接“双击”安装
2.指令安装
2.1.终端命令行安装
```bash
$ sudo dpkg -i <package.deb>
```

2.2.终端命令行卸载
```bash
$ sudo dpkg -r <package>
```
# `dpkg`指令的其他用法
```bash
$ dpkg -i <package.deb>     #安装一个 Debian 软件包，如手动下载的文件。
$ dpkg -c <package.deb>     #列出 package.deb 的内容。
$ dpkg -I <package.deb>     #从 package.deb 中提取包信息。
$ dpkg -r <package>         #移除一个已安装的包。
$ dpkg -P <package>：       #完全清除一个已安装的包。和 remove 不同的是，remove 只是删掉数据和可执行文件，purge 另外还删除所有的配制文件。
$ dpkg -L <package>     #列出 package 安装的所有文件清单。
$ dpkg -s <package>     #显示已安装包的信息。
$ dpkg -S <package>     #查看软件在哪个包里；
```
