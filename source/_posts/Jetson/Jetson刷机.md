---
title: Jetson刷机
categories:
    - Jetson
---
# 准备工作
 - Ubuntu20.04系统的PC机
 - USB-TypeC转接线
 - Jetson

<!-- more -->
# 刷机系统
step1：准备Ubuntu20.04版本PC机
虚拟机也可以，但是要求分配的内存要**大于120G**，因为下载的jetpack安装包很大。
Ubuntu20.04版本对应jetpack 5.1.3版本

step2：下载SDK manager
[SDK manager](https://developer.nvidia.com/sdk-manager)是官方提供的刷机软件

step3：USB线连接Jetson和PC机

step4：Jetson进入Recovery模式
方式一：Jetson关机状态时，长按SW3（REC按键）然后接通电源线，等待PC机上弹出连接成功，松开SW3
方式二：Jetson开机状态时，需要先长按住SW3（REC按键），然后按下SW2(Reset键)，先松开SW2(Reset键)，再松开SW3（REC按键）。

step5：SDK manager选择刷机版本
 - 取消勾选Host Machine
 - jetpack版本选择5.1.3

step5：刷Jetson Linux
刷系统就可以了。组件可以先不刷，直接在Jetson上联网使用apt安装

# 安装组件
step1：安装官方组件
```bash
$ sudo apt update 
$ sudo apt install nvidia-jetpack
```

step2：补全环境
```bash
$ sudo apt update
$ sudo apt install python3
$ sudo apt install python3-pip
```

step3：安装jtop
```bash
$ sudo pip3 install -U pip
$ sudo pip3 install jetson-stats
```
可以使用jtop查看组件版本。

# 安装cuda 11.4
step1：浏览器搜索“cuda 11.4”找到官网[CUDA Toolkit 11.4 Downloads - NVIDIA Developer](https://developer.nvidia.com/cuda-11-4-0-download-archive)
step2：Linux->arm64-sbsa->Native->Ubuntu->20.04->deb(network)
step3：运行官网提供的对应命令行
step4：添加cuda的环境变量
```bash
$ sudo vim ~/.bashrc
```
在其中添加环境路径
```bash
export PATH=/usr/local/cuda-11.4/bin:$PATH
```
重新加载.bashrc文件，以便立即生效
```bash
$ source ~/.bashrc
```
查看CUDA版本信息：
```bash
$ nvcc --version
```

# question
**什么是native compiler？什么是cross compiler？**
 - build - 编译GCC的平台
 - host - 运行GCC的平台
 - target - GCC编译产生的应用程序的运行平台

1. 三者全部相同（build = host = target）的就是native compiler，例如我们在PC上装的Ubuntu或者Fedora里面带的GCC，就是native compiler。
2. 如果build = host，但是target跟前两者不同，就是cross compiler。比如开发手机应用程序的编译器，通常运行在PC或Mac上，但是编译出来的程序无法直接在PC或Mac上执行。
3. 三者都不同的话，叫做Canadian cross。