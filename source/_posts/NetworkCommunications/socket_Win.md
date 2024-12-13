---
title: socket-Windows
ccategories:
	- 网络通信
---
# 通信流程

## 服务器

1. 初始化Winsock
2. 创建套接字
3. 绑定套接字
4. 侦听客户端的套接字
5. 接收来自客户端的连接
6. 接收和发送数据
7. 断开连接

<!-- more -->

## 客户端

1. 初始化Winsock
2. 创建套接字
3. 连接到该服务器
4. 发送和接收数据
5. 断开连接

# Windows下使用CMake

1. CMake

   * [CMake官网](https://cmake.org/download/)下载并安装
   * 无需重启，更新环境变量指令：refreshenv
2. make

   * 安装[MinGW](https://github.com/niXman/mingw-builds-binaries/releases)
   * 添加环境变量：bin目录添加到PATH
   * bin目录中mingw-make.exe重命名为make.exe
3. 编译指令

   * cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
   * make

# Winsock入门

```C++
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdio.h>

#pragma comment(lib, "Ws2_32.lib")

int main() {
  return 0;
}
```

1. winsock2.h头文件包含大多数Winsock函数，结构和定义
2. ws2tcpip.h头文件包含了用于处理TCP/IP网络协议的特定功能
3. 对于winsock2.h需要连接到ws2_32.lib

## 初始化Winsock

调用Winsock函数（应用程序或DLL）的所有进程，都必须在调用Winsock函数之前初始化Windows套接字DLL，从而确保Winsock在系统上受支持。

1. 创建名为wsaDate的WSADATA对象

   ```C++
   WSADATA wsaData;
   ```
2. 调用[WSAStartup](https://learn.microsoft.com/zh-cn/windows/win32/api/winsock/nf-winsock-wsastartup)并将其值作为整数返回，并检查错误。

   ```C++
   int iResult;

   // Initialize Winsock
   iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
   if (iResult != 0) {
       printf("WSAStartup failed: %d\n", iResult);
       return 1;
   }
   ```

- WSAStartup函数用于初始化Winsock DLL，在调用任何Winsock函数之前，必须成功调用该函数。
- MAKEWORD(2,2)指定所需的Winsock的版本号，这里表示版本2.2

## 为客户端创建套接字

初始化之后，必须实例化socket对象，以供客户端使用。

1. 声明包含sockaddr结构的addrinfo对象并初始化这些值。

   ```C++
   struct addrinfo *result = NULL;
   struct addrinfo *ptr = NULL;
   struct addrinfo hints;
   ZeroMemory(&hints, sizeof(hints));
   hints.ai_family   = AF_INET;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_protocol = IPPROTO_TCP;
   ```
2. 调用getaddrinfo函数，请求传递的服务器名称的IP地址。

   ```C++
   char *node = "baidu.com";
   char *service = "http";

   // Resolve the server address and port
   iResult = getaddrinfo(node, service, &hints, &result);
   if (iResult != 0) {
       printf("getaddrinfo failed: %d\n", iResult);
       WSACleanup();
       return 1;
   }
   ```

示例代码：

```C++
#include <WinSock2.h>
#include <WS2tcpip.h>
#include <stdio.h>
#pragma comment(lib, "Ws2_32.lib")
#define DEFAULT_PORT "27015"

int main(){
    WSADATA WSAData;
    struct addrinfo* result = NULL;
    struct addrinfo* ptr = NULL;
    struct addrinfo  hints;
    char *node = "baidu.com";
    char *service = "http";

    // 初始化Winsock
    int iResult = WSAStartup(MAKEWORD(2,2), &WSAData);
    if(iResult != 0){
        printf("WSAStartup is failed:%d...\n", iResult);
        return 1;
    }

    // 设置hints结构
    ZeroMemory(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    //解析地址
    iResult = getaddrinfo(node, service, &hints, &result);
    if (iResult != 0) {
        printf("getaddrinfo failed: %d\n", iResult);
        WSACleanup();
        return 1;
    }

    // 遍历结果链表
    for (ptr = result; ptr != NULL; ptr = ptr->ai_next) {
        struct sockaddr_in *ipv4 = (struct sockaddr_in *)ptr->ai_addr;
        printf("IP Address: %s\n", inet_ntoa(ipv4->sin_addr));
    }

    // 清理
    freeaddrinfo(result);
    WSACleanup();
    return 0;
}
```

## 连接到套接字

调用connect函数，将创建的套接字和sockaddr结构作为参数传递。 检查常规错误。

```C++
iResult = connect( ConnectSocket, ptr->ai_addr, (int)ptr->ai_addrlen);
if (iResult == SOCKET_ERROR) {
    closesocket(ConnectSocket);
    ConnectSocket = INVALID_SOCKET;
}

freeaddrinfo(result);

if (ConnectSocket == INVALID_SOCKET) {
    printf("Unable to connect to server!\n");
    WSACleanup();
    return 1;
}
```

## 在客户端上发送和接收数据

```C++
#define DEFAULT_BUFLEN 512
int recvbuflen = DEFAULT_BUFLEN;
const char *sendbuf = "this is a test";
char recvbuf[DEFAULT_BUFLEN];
int iResult;

// Send an initial buffer
iResult = send(ConnectSocket, sendbuf, (int) strlen(sendbuf), 0);
if (iResult == SOCKET_ERROR) {
    printf("send failed: %d\n", WSAGetLastError());
    closesocket(ConnectSocket);
    WSACleanup();
    return 1;
}

printf("Bytes Sent: %ld\n", iResult);

// shutdown the connection for sending since no more data will be sent
// the client can still use the ConnectSocket for receiving data
iResult = shutdown(ConnectSocket, SD_SEND);
if (iResult == SOCKET_ERROR) {
    printf("shutdown failed: %d\n", WSAGetLastError());
    closesocket(ConnectSocket);
    WSACleanup();
    return 1;
}

// Receive data until the server closes the connection
do {
    iResult = recv(ConnectSocket, recvbuf, recvbuflen, 0);
    if (iResult > 0)
        printf("Bytes received: %d\n", iResult);
    else if (iResult == 0)
        printf("Connection closed\n");
    else
        printf("recv failed: %d\n", WSAGetLastError());
} while (iResult > 0);
```

示例代码：

```C++
#include <WinSock2.h>
#include <WS2tcpip.h>
#include <stdio.h>
#pragma comment(lib, "Ws2_32.lib")
#define DEFAULT_PORT "27015"
#define DEFAULT_BUFLEN 512

int main(){
    WSADATA WSAData;
    struct addrinfo* result = NULL;
    struct addrinfo* ptr = NULL;
    struct addrinfo  hints;
    char *node = "baidu.com";
    char *service = "http";
    SOCKET ConnectSocket = INVALID_SOCKET;

    // 初始化Winsock
    int iResult = WSAStartup(MAKEWORD(2,2), &WSAData);
    if(iResult != 0){
        printf("WSAStartup is failed:%d...\n", iResult);
        return 1;
    }

    // 设置hints结构
    ZeroMemory(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    //解析地址
    iResult = getaddrinfo(node, service, &hints, &result);
    if (iResult != 0) {
        printf("getaddrinfo failed: %d\n", iResult);
        WSACleanup();
        return 1;
    }

    // 遍历结果链表
    for (ptr = result; ptr != NULL; ptr = ptr->ai_next) {
        struct sockaddr_in *ipv4 = (struct sockaddr_in *)ptr->ai_addr;
        printf("IP Address: %s\n", inet_ntoa(ipv4->sin_addr));
        ConnectSocket = socket(ptr->ai_family, ptr->ai_socktype, ptr->ai_protocol);
        if (ConnectSocket == INVALID_SOCKET) {
            continue; // Create socket failed, try next address
        }

        iResult = connect(ConnectSocket, ptr->ai_addr, (int)ptr->ai_addrlen);
        if (iResult == SOCKET_ERROR) {
            closesocket(ConnectSocket);
            ConnectSocket = INVALID_SOCKET;
            continue;
        }
        break;
    }

    freeaddrinfo(result);
    if (ConnectSocket == INVALID_SOCKET) {
        printf("Unable to connect to server!\n");
        WSACleanup();
        return 1;
    }

    int recvbuflen = DEFAULT_BUFLEN;
    const char *sendbuf = "this is a test";
    char recvbuf[DEFAULT_BUFLEN];

    // Send an initial buffer
    iResult = send(ConnectSocket, sendbuf, (int)strlen(sendbuf), 0);
    if (iResult == SOCKET_ERROR) {
        printf("send failed: %d\n", WSAGetLastError());
        closesocket(ConnectSocket);
        WSACleanup();
        return 1;
    }
    printf("Bytes Sent: %ld\n", iResult);

    iResult = shutdown(ConnectSocket, SD_SEND);
    if (iResult == SOCKET_ERROR) {
        printf("shutdown failed: %d\n", WSAGetLastError());
        closesocket(ConnectSocket);
        WSACleanup();
        return 1;
    }

    do {
        iResult = recv(ConnectSocket, recvbuf, recvbuflen, 0);
        if (iResult > 0) {
            printf("Bytes received: %d\n", iResult);
            recvbuf[iResult] = '\0'; // Null-terminate the received data
            printf("Received data: %s\n", recvbuf);
        } else if (iResult == 0) {
            printf("Connection closed\n");
        } else {
            printf("recv failed: %d\n", WSAGetLastError());
        }
    } while (iResult > 0);

    closesocket(ConnectSocket);
    iResult = WSACleanup();
    if (iResult != 0) {
        printf("WSACleanup failed: %d\n", iResult);
        return 1;
    }
    return 0;
}
```

## 断开客户端的连接

1. 当客户端将数据发送到服务器后，可以调用shutdown函数，指定SD_SEND关闭套接字的发送端。 这允许服务器释放此套接字的某些资源。 客户端应用程序仍可接收套接字上的数据。

   ```C++
   // shutdown the send half of the connection since no more data will be sent
   iResult = shutdown(ConnectSocket, SD_SEND);
   if (iResult == SOCKET_ERROR) {
       printf("shutdown failed: %d\n", WSAGetLastError());
       closesocket(ConnectSocket);
       WSACleanup();
       return 1;
   }
   ```
2. 客户端应用程序完成接收数据后，调用closesocket函数关闭套接字，使用Windows套接字DLL完成客户端应用程序时，调用WSACleanup函数释放资源。

   ```C++
   // cleanup
   closesocket(ConnectSocket);
   WSACleanup();
   return 0;
   ```


# 参考文档

[Windows套接字](https://learn.microsoft.com/zh-cn/windows/win32/winsock/about-clients-and-servers)

[Windows Socket API-us](https://learn.microsoft.com/en-us/windows/win32/api/_winsock/)

[Windows Socket API-zh](https://learn.microsoft.com/zh-cn/windows/win32/api/winsock/nf-winsock-wsastartup)
