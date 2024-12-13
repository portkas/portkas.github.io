---
title: apt换源
categories: 
    - PC
---

Ubuntu24.04换源
> Ubuntu24.04源文件地址已经更换为`etc/apt/source.list.d/ubuntu.sources`
<!-- more -->
1.备份当前源列表
```bash
sudo cp /etc/apt/sources.list.d/ubuntu.sources  /etc/apt/sources.list.d/ubuntu.sources.bak
```

2.添加阿里云源
```bash
$ sudo vim /etc/apt/sources.list.d/ubuntu.source

# 在文本编辑器中粘贴以下内容
# 阿里云
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

# 更新源列表和系统软件包
```bash
$ sudo apt-get update
$ sudo apt-get upgrade
```

# 清华源
```
Types: deb
URIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

# 中科大源
```
Types: deb
URIs: http://mirrors.ustc.edu.cn/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```
