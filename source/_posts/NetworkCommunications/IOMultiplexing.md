---
title: IO多路复用
categories:
	- NetworkCommunications
---
# 概述

1. 文件描述符
2. IO多路复用
   1. select
   2. poll
   3. epoll

<!-- more -->

# 文件描述符

### 文件描述符

服务器端有两种文件描述符：负责监听的文件描述符，负责通信的文件描述符：

监听文件描述符：

1. Read Buffer：存储客户端的连接请求 -> accept()
2. Write Buffer：当服务器接收到客户端的连接请求时，需要对其进行回应

通信文件描述符：

1. Read Buffer：存储客户端发送的通信数据 -> read()
2. Write Buffer：存储要给客户端发送的数据 -> write()

accept(), read(), write()三个函数都是阻塞函数，以accept()为例：

* 当Read Buffer内有数据时即有连接请求时，解除阻塞，建立连接；
* 当Read Buffer内没有数据时，则一直阻塞；

在单线程下，是不能同时处理这三个函数的，如果有一个函数发生阻塞，另外两个也只能阻塞。解决办法：

1. 多线程
2. 多进程
3. IO多路复用

### IO多路复用

使用IO多路复用函数委托内核检测服务器端所有的文件描述符（通信和监听两类)，这个检测过程会导致进程/线程阻塞，如果检测到已就绪的文件描述符就解除阻塞，并将这些已就绪的文件描述符传出。相当于本来有三个地方会阻塞，现在把三个集合到一起进行检测，从而只有一个地方会阻塞，这样在阻塞期间可以同时对三者进行检测。

处理流程：

1. 用IO多路复用函数委托内核检测服务器端所有的文件描述符
2. 根据类型对传出的所有已就绪文件描述符进行判断，并做出不同的处理
   1. 监听的文件描述符：和客户端建立连接
      1. 此时调用accept()是不会导致程序阻塞的，因为IO多路复用函数已经检测过了，确定此时监听的文件描述符是就绪的即有新的请求
   2. 通信的文件描述符：调用通信函数和已建立连接的客户端通信
      1. 此时调用read()/recv()函数不会阻塞程序，因为通信的文件描述符是就绪的即读缓冲区以有数据
      2. 此时调用write()/send()函数不会阻塞程序，因为写缓存不满，可以写数据
3. 对文件描述符进行下一轮的检测，循环往复

与多进程和多线程技术相比，I/O多路复用技术的最大优势是系统开销小，系统不必创建进程/线程，也不必维护这些进程/线程，从而大大减小了系统的开销。

# select

1. 可以跨平台；
2. 使用select能够检测的最大文件描述符个数有上限，默认是1024；
3. fd_set不可以重用；
4. 待测集合需要频繁在用户区和内核区之间进行数据的拷贝；
5. 内核对select传递进来的待测集合的检测方式是线性的；

```cpp
#include <sys/select.h>
struct timeval {
    time_t      tv_sec;         /* seconds */
    suseconds_t tv_usec;        /* microseconds */
};

int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval * timeout);
```

函数参数：

* nfds：委托内核检测的这三个集合中最大的文件描述符加1
  * 内核需要现行便利这些集合中的文件描述符，这个值是循环结束的条件；
  * 在Windows中这个参数是无效的，指定为-1
* readfds：文件描述符的集合，内核只检测这个集合中文件描述符对应的读缓冲区
  * 传入传出参数，如果不需要可以指定为NULL
* writefds：文件描述符的集合, 内核只检测这个集合中文件描述符对应的写缓冲区
  * 传入传出参数，如果不需要使用这个参数可以指定为NULL
* exceptfds：文件描述符的集合, 内核检测集合中文件描述符是否有异常状态
  * 传入传出参数，如果不需要使用这个参数可以指定为NULL
* timeout：超时时长，用来强制解除select()函数的阻塞的
  * NULL：函数检测不到就绪的文件描述符会一直阻塞。
  * 等待固定时长（秒）：函数检测不到就绪的文件描述符，在指定时长之后强制解除阻塞，函数返回0
  * 不等待：函数不会阻塞，直接将该参数对应的结构体初始化为0即可。

返回值：

* 大于0：成功，返回集合中已就绪的文件描述符的总个数
* 等于-1：函数调用失败
* 等于0：超时，没有检测到就绪的文件描述符

```cpp
// 将文件描述符fd从set集合中删除，即将fd对应的标志位置设置为0
void FD_CLR(int fd, fd_set *set);

// 判断文件描述符fd是否在set集合中，即读取fd对应的标志位是否为1
int FD_ISSET(int fd, fd_set *set);

// 将文件描述符fd添加到set集合中，即将fd对应的标志位设置为1
int FD_SET(int fd, fd_set *set);

// 将set集合中所有的文件描述符对应的标志为设置为0
int FD_ZERO(fd_set *set);
```

# poll