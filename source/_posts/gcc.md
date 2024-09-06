---
title: gcc
categories:
    - Linux
---
# gcc编译流程
```bash
# 1.预处理
$ gcc -E main.c -o main.i

# 2.编译
$ gcc -S main.i -o main.s

# 3.汇编
$ gcc -c main.s -o main.o

# 4.链接
$ gcc main.o -o main
```
<!-- more -->
# gcc常用参数
* -E：预处理，不进行编译
* -S：编译，但不汇编
* -c：编译并汇编，但不链接
* -o：指定生成的文件名
* -I：指定include包含文件的目录
* -g：生成调试信息
* -D：编译的时候指定一个宏
* -W：不生成任何警告
* -Wall：生成所有警告
* -On：代码优化
* -l：编译的时候，指定使用的库
* -L：指定编译的时候搜索库的路径
* -fpic：生成与位置无关代码
* -shared：生成共享目标文件
* -std：指定标准