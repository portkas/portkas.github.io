---
title: Linux基础
categories:
    - Linux
---
# Linux内核
1.进程调度 SCHED
2.内存管理 MMU
3.虚拟文件系统 VFS
4.网络接口
5.进程间通信
<!-- more -->
# Linux目录
* bin：存储可执行程序，比如各种命令的可执行程序
* sbin：root用户使用的一些二进制可执行程序
* etc：配置文件目录，存储应用程序的配置文件
* lib：系统或安装的软件所使用的静态库和动态库
* media：挂在目录，挂在外部设备
* mnt：临时挂载目录，比如U盘可以挂载在这个目录下
* proc：内存使用的映射目录，给操作系统使用
* tmp：临时目录，重启电脑数据被自动删除
* boot：存储开机相关的设置
* home：普通用户的家目录
* root：root用户的家目录
* dev：设备目录，所有硬件会被抽象成文件存储起来比如键盘，鼠标
* opt：第三方软件的安装目录
* var：日志文件
* usr：系统的资源目录
    * /usr/bin：可执行二进制程序
    * /usr/include：标准头文件目录
    * /usr/local：安装的第三方软件，同opt目录

# 快捷键
|快捷键|功能|
|:---:|:---:|
|Ctrl+a|光标移动到命令行行首|
|Ctrl+e|光标移动到命令行行尾|
|Ctrl+u|删除光标前的字符串|
|Ctrl+k|删除光标后的字符串|

# 文件管理命令
## 1.在邻近的两个目录之间切换 cd
```bash
#通过cd进入目录1
$ cd /home/zhm/Desktop/Linux    

#通过cd进入目录2
$ cd /Download/Clash

#在两个目录之间切换
$ cd -
```

## 2.ls命令
```bash
#查看当前目录下所有文件包括隐藏文件
$ ls -a

#显示文件详细信息
$ ls -l #可以缩写成ll
drwxrwxr-x 5 zhm zhm 4.0K  9月  4 21:25 ./
drwxr-xr-x 3 zhm zhm 4.0K  9月  4 13:52 ../
drwxrwxr-x 5 zhm zhm 4.0K  9月  4 18:29 gcc/
drwxrwxr-x 2 zhm zhm 4.0K  9月  4 21:25 makefile/
drwxrwxr-x 2 zhm zhm 4.0K  9月  3 21:03 search/
```
* 文件类型
    * -:普通文件
    * d:目录
    * l:软链接文件
    * c:字符设备
    * b:块设备
    * p:管道文件
    * s:本地套接字文件
* 文件所有者权限
* 文件所属组权限
* 其他人权限
* 硬链接计数
* 文件所有者
* 文件所有组
* 文件大小
* 文件修改时间
* 文件名

## 3.删除文件或目录
```bash
# 删除文件
$ rm file1.c file2.c

# 删除目录
$ rm dir -r

# 强制删除目录
$ rm dir -rf
```

## 4.拷贝文件或目录
```bash
# 拷贝文件（文件不存在则创建，文件存在则覆盖）
$ cp fileA fileB

# 拷贝目录（拷贝目录需要参数 -r）
# 情景1：目录A存在，目录B不存在（创建B，并将A放入B）
$ cp dirA dirB -r

# 情景2：目录A存在，目录B也存在（直接将A放入B）
$ cp dirA dirB -r

# 情景3：把目录A中的所有文件拷贝到目录B中（A中文件放入B）
$ cp dirA/* dirB -r
```

## 5.查看文件内容
```bash
$ cat filename
$ more filename
    - 回车：显示下一行
    - 空格：向下滚动一屏
    - b：返回上一屏
    - q：退出
$ less filename
    - 空格：向下翻页
    - b：向上翻页
    - 回车：显示下一行
    - 上下键：上下滚动
    - q：退出
```

## 6.创建链接
```bash
# 软链接：相当于创建快捷方式
# 创建软链接并放到另一个目录
$ ln -s hello /home/zhm/Desktop/Linux/search/link/hello.link

# 硬链接：多个文件指向同一个内存
$ ln hello ./link/hello.link
```

## 7.文件属性
### 7.1 修改文件权限 chmod
```bash
# 语法格式
# chmod who [+|-|=] mod filename
# chmod [+|-|=] mod filename
    - who:
        - u：user 文件所有者
        - g：group 文件所有组
        - o：other 其他用户
        - a：all 以上三类
    - [+|-|=]:
        - +：添加权限
        - -：去除权限
        - =：覆盖权限
    - mod
        - r/4：读权限
        - w/2：写权限
        - x/1：执行权限
        - -/0：没有权限

# 示例：给文件所有者添加执行权限
$ chmod u +x hello

# 示例：给所有用户添加读写执行权限
# 7 = 4 + 3 + 1（读 + 写 + 执行）
$ chmod 777 hello
```

### 7.2 修改文件所有者 chown
创建新用户的时候，系统会自动创建出对应用户名组，比如创建一个新的用户wwl，则会同时创建出一个新的用户组wwl。默认情况下，文件通过哪个用户创建出来，就属于哪个用户以及属于用户对应的组。
```bash
# 修改文件所有者
# sudo chown 新的所有者 文件名
$ sudo chown wwl <filename>

# 修改文件所有者和所属组
# sudo chown 新的文件所有者：新的文件所属组 文件名
$ sudo chown wwl:wwl <filename>
```

### 7.3 修改文件所属组 chgrp
```bash
# sudo chgrp 新的组 文件名
$ sudo chgrp wwl <filename>
```

## 8.which
```bash
# 查看要执行的命令所在的实际路径
$ which ls
/usr/bin/ls
```

## 9.输出重定向
```bash
# > : 将文件内容写入到指定文件中，覆盖原数据
# >> : 将文件内容追加到指定文件的尾部
$ cat hello.c > hello.cpp
$ date >> time.txt
```

# 用户管理命令
## 1.切换用户 su
```bash
# 使用 su 只切换用户，当前的工作目录不会变化
$ su wwl

# 使用 su - 不仅会切换用户，工作目录也会切换为当前用户的家目录
$ su - wwl 
```

## 2.添加用户 adduser
```bash
# sudo adduser <username>
$ sudo adduser wwl
```

## 3.删除用户 userdel
```bash
# sudo userdel <username> -r
$ sudo userdel wwl -r
```

## 4.添加和删除用户组 groupadd/groupdel
```bash
# 基于普通用户创建新的用户组
$ sudo groupadd <new-group-name>

# 基于普通用户删除已经存在的用户组
$ sudo groupdel <group-name>
```
