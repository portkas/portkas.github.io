---
title: 网络编程代码
categories:
	- NetworkCommunications
---
# 任务

1. 单线程以及多线程C/S
2. 使用select实现单线程以及多线程C/S
3. 使用poll实现单线程以及多线程C/S
4. 使用epoll实现单线程以及多线程C/S

<!-- more -->

# 单线程C/S

### 服务器端

```cpp
#include <iostream>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#define PORT 25500

int main(){
    // 创建监听套接字socket
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if(sockfd == -1){
        perror("socket");
        exit(0);
    }

    // 绑定本地IP和端口bind
    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    addr.sin_addr.s_addr = INADDR_ANY;
    int ret = bind(sockfd, (sockaddr*)&addr, sizeof(addr));
    if(ret == -1){
        perror("bind");
        exit(0);
    }

    // 设置监听listen
    ret = listen(sockfd, 128);
    if(ret == -1){
        perror("listen");
        exit(0);
    }

    // 建立连接
    socklen_t addrlen = sizeof(addr);
    int cfd = accept(sockfd, (sockaddr*)&addr, &addrlen);
    if(cfd == -1){
        perror("accept");
        exit(0);
    }else{
        char buffer[1024];
        while(1){
            memset(buffer, 0, sizeof(buffer));
            ssize_t len = read(cfd, buffer, sizeof(buffer));
            if(len < 0){
                perror("read");
                exit(0);
            }else if(len == 0){
                std::cout<<"客户端断开连接...."<<std::endl;
                break;
            }else{
                for(int i=0; i<len; ++i){
                    if(buffer[i] >= 'a' && buffer[i] <= 'z') {
                        buffer[i] -= 'a' - 'A';
                    }
                }
                write(cfd, buffer, len);
            }
        }
    }
    ret = close(sockfd);
    ret = close(cfd);
    if(ret == -1){
        perror("close");
        exit(0);
    }
    return 0;
}
```

1. `#include<arpa/inet.h>`包含了一些字节序转换函数；
2. `#include<sys/socket.h>`包含了套接字通信函数；
3. `#include<unistd.h>`包含了read，write，close等函数；
4. `#include<string.h>`包含了memset等函数；
5. 文件描述符会按照从小到达的顺序创建，比如这个程序sockfd将为3，cfd将为4；
6. 文件描述符0为stdin：标准输入；
7. 文件描述符1为stdout：标准输出；
8. 文件描述符2为stderr：标准错误输出；
9. 函数具体参数没必要特意去记，熟练使用man文档查阅


### 客户端

```cpp
#include <iostream>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#define PORT 25500
#define serverIP "49.123.87.90"

int main(){
    int cfd = socket(AF_INET, SOCK_STREAM, 0);
    if(cfd == -1){
        perror("socket");
        exit(0);
    }

    int ret;
    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    // addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    ret = inet_pton(AF_INET, serverIP, &addr.sin_addr.s_addr);
    ret = connect(cfd, (sockaddr*)&addr, sizeof(addr));
    if (ret == -1) {
        perror("connect");
        exit(0);
    }

    int i=0;
    while(1)
    {
        char sendbuffer[1024];
        char recvbuffer[1024];
        sprintf(sendbuffer, "data: %d\n", i++);
        write(cfd, sendbuffer, strlen(sendbuffer)+1);
        read(cfd, recvbuffer, sizeof(recvbuffer));
        printf("send buf: %s", sendbuffer);
        printf("recv buf: %s\n", recvbuffer);
        sleep(1);
    }

    ret = close(cfd);
    if(ret == -1){
        perror("close");
        exit(0);
    }
    return 0;
}
```

1. ip从主机字节序转换到网络字节序
   ```cpp
   // way-1
   addr.sin_addr.s_addr = inet_addr("127.0.0.1");

   // way-2
   int ret = inet_pton(AF_INET, serverIP, &addr.sin_addr.s_addr);
   ```


# 多线程C/S
