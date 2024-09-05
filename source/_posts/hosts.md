---
title: hosts
categories:
    - PC
---
在Ubuntu上安装nvm遇到：curl: (28) Failed to connect to raw.githubusercontent.com port 443: Connection timed out [closed]
1.打开`/etc/hosts`
```bash
$ sudo vim /etc/hosts
```
<!-- more -->
2.查询可用IP
使用[ipaddress](https://www.ipaddress.com/website/)网站查询`github.com`,`ssh.github.com`,`raw.githubusercontent.com`网站的可用IP

3.在末尾添加以下IP地址
```
140.82.114.3  github.com
140.82.113.36  ssh.github.com
199.232.68.133 raw.githubusercontent.com
```

4.保存文件并退出

5.可以使用ping查看域名是否有received
```
$ ping 199.232.68.133
PING 199.232.68.133 (199.232.68.133) 56(84) bytes of data.
64 bytes from 199.232.68.133: icmp_seq=1 ttl=43 time=234 ms
64 bytes from 199.232.68.133: icmp_seq=2 ttl=43 time=234 ms
64 bytes from 199.232.68.133: icmp_seq=3 ttl=43 time=234 ms
64 bytes from 199.232.68.133: icmp_seq=4 ttl=43 time=233 ms
^C
--- 199.232.68.133 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 233.337/233.849/234.302/0.421 ms
```

**ps.为什么要这样做呢??? hosts是什么配置文件呢???**
**hosts文件是什么？**
在Linux系统中，`/etc/hosts`文件是一个本地的DNS解析文件，用于将IP地址和主机名映射起来。当你访问某个域名时，系统会首先检查这个文件，如果在这里找到了对应的IP地址，就会直接使用，而不再通过外部DNS服务器查询。
**为什么要这么做？**
这是将GitHub相关的域名（如 github.com、ssh.github.com 和 raw.githubusercontent.com）手动映射到指定的IP地址。这么做的目的通常有以下几种可能：
* 解决访问问题：有时候由于DNS解析缓慢或者网络封锁，GitHub相关服务的域名可能会无法访问，通过手动在/etc/hosts中添加这些映射，可以直接访问指定的IP，绕过DNS解析。
* 加快访问速度：如果你已经知道某个域名的IP地址，手动添加可以减少系统查询外部DNS的时间，从而提升访问速度。
* 绕过DNS劫持：在某些情况下，网络服务提供商或某些恶意软件可能会劫持DNS请求，将你引导到错误的网站，通过手动配置IP可以避免这种情况。

IP地址可能会随着时间变化，所以如果GitHub更新了服务器的IP地址，而你还在使用旧的配置，可能会导致访问失败。
