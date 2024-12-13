---
title: Github的SSH配置
categories:
    - Git
---
# 1.创建公私密钥
```bash
$ ssh-keygen -t rsa -C "Github注册的邮箱地址"
$ cat ～/.ssh/id_rsa.pub
# ps.在windows系统中.ssh文件在C:\Users\你的用户名\.ssh目录下
```

<!-- more -->
# 2.配置公钥
1.github -> 个人头像 -> setting -> SSH and GPG keys -> New SSH key
2.复制id_rsa.pub的内容到Key中
3.Title的内容自定义

# 3.验证是否设置成功
```bash
$ ssh -T git@github.com
Hi portkas! You've successfully authenticated, but GitHub does not provide shell access.
```

# 4.Q&A
SSH登录安全性由非对称加密保证，产生密钥时，一次产生两个密钥，一个公钥，一个私钥，在git中一般命名为id_rsa.pub, id_rsa。
## 如何使用生成的一个私钥一个公钥进行验证呢？
本地生成一个密钥对，其中公钥放到远程主机，私钥保存在本地，当本地主机需要登录远程主机时，本地主机向远程主机发送一个登录请求，远程收到消息后，随机生成一个字符串并用公钥加密，发回给本地。本地拿到该字符串，用存放在本地的私钥进行解密，再次发送到远程，远程比对该解密后的字符串与源字符串是否等同，如果等同则认证成功。
## 每使用一台主机都要配？
每使用一台新主机进行git远程操作，想要实现无密，都需要配置。并不是说每个账号配一次就够了，而是每一台主机都需要配。
## 配了为什么就不用密码了？
因为配置的时候是把当前主机的公钥放到了你的github账号下，相当于当前主机和你的账号做了一个关联，你在这台主机上已经登录了你的账号，此时此刻github认为是该账号主人在操作这台主机，在配置ssh后就信任该主机了。所以下次在使用git的时候即使没有登录github，也能直接从本地push代码到远程了。
