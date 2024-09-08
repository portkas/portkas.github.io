---
title: makefile
categories:
    - Linux
---
# 规则
```
target:depend
    commend
```
每条规则由三部分组成：目标（target），依赖（depend），命令（comment）
* 目标：目标可以有多个
* 依赖：依赖可有可无
* 命令：前面要有Tab缩进，shell命令

<!-- more -->
# 原理
make命令执行的时候根据时间戳判定是否执行makefile文件中相关规则的命令。
* 目标是通过依赖生成的，目标时间戳>所有依赖时间戳，则不会执行规则中的命令
* 目标时间戳<某些依赖的时间戳，则执行规则中的命令
* 目标文件不存在，执行规则中的命令

# 变量
## 自定义变量
```
# 定义变量（必须要同时赋值）
变量名=变量值

# 取变量值
$(变量名)
```

## 预定义变量
|变量名|含义|默认值|
|:---:|:---:|:---:|
|AR|生成静态库程序|ar|
|AS|汇编编译器|as|
|CC|C语言编译器|cc|
|CPP|C语言预编译器|$(CC) -E|
|CXX|C++编译器|g++|
|RM|删除文件程序|rm -f|
|ARFLAGS|生成静态库程序的选项|无|
|ASFLAGS|汇编语言编译器编译选项|无|
|CFLAGS|C语言编译器的编译选项|无|
|CPPFLAGS|C语言预编译器的编译选项|无|
|CXXFLAGS|C++编译器的编译选项|无|
```makefile
# 示例：
obj=main.o sub.o add.o
target=calc
CFLAGS=-O3
$(target):$(obj)
    $(CC) $(obj) -o $(target) $(CFLAGS)
```

## 自动变量
|变量|含义|
|:---:|:---:|
|$@|目标文件(target)的完整名称|
|$<|第一个依赖文件的名称|
|$^|所有依赖文件的名称，以空格分开，不包含重复依赖|
|$*|目标文件的名称，不包含扩展名|
|$?|依赖项中，所有比目标文件时间戳晚的依赖文件，以空格分开|
```makefile
# 示例：
$(target):$(obj)
    gcc $^ -o $@
```

# 模式匹配
使用模式匹配前：
```makefile
calc:add.o  div.o  main.o  mult.o  sub.o
        gcc  add.o  div.o  main.o  mult.o  sub.o -o calc

add.o:add.c
        gcc add.c -c

div.o:div.c
        gcc div.c -c

main.o:main.c
        gcc main.c -c

sub.o:sub.c
        gcc sub.c -c

mult.o:mult.c
        gcc mult.c -c
```

使用模式匹配后：
```makefile
calc:add.o  div.o  main.o  mult.o  sub.o
        gcc  add.o  div.o  main.o  mult.o  sub.o -o calc

%.o:%.c
	gcc $< -c
```

# 函数
## wildcard
函数功能:获取指定目录下指定类型的文件名，其返回值是以空格分割的指定目录下符合条件的文件名列表。
.
├── include
│   └── head.h
├── main.c
├── Makefile
└── src
    ├── add.c
    ├── div.c
    ├── mult.c
    └── sub.c
```makefile
# 语法：
$(wildcard 目录列表)

# 示例：
src=$(wildcard *.c ./src/*.c)
```

## patsubst
```makefile
# 语法：
$(patsubst <pattern>, <replacement>, <text>)

# 示例：将变量src中的所有文件名的后缀替换成.o
obj=$(patsubst %.c, %.o, $(src))
```

# makefile示例
.
├── include
│   └── head.h
├── main.c
├── Makefile
└── src
    ├── add.c
    ├── div.c
    ├── mult.c
    └── sub.c
```makefile
# 定义变量
target=main
include=./include
CFLAGS=-O3 -g -Wall

# 搜索源文件
src=$(wildcard *.c ./src/*.c)

# 替换成.o结尾
obj=$(patsubst %.c, %.o, $(src))

# 对汇编文件进行链接
$(target):$(obj)
   gcc $^ -o $@

# 对源文件进行逐个汇编
%.o:%.c
   gcc $< -c -I$(include) -o $@

# clean
.PHONY: clean
clean:
   rm $(obj) $(target) -f
```

# 扩展
## 递归扩展变量（=）
```makefile
.PHONY: all
foo = $(bar)
bar = $(hello)
hello = world

all:
    @echo $(foo)
```
```bash
$ make
world
```

## 简单扩展变量（:=）
对于这种变量，make只对其进行一次扫描和扩展。
```makefile
.PHONY: all
x = foo
y = $(x) b
x = later

xx := foo
yy := $(xx) b
xx := later

all:
    $echo "x = $(y), xx = $(yy)"
```
```bash
$ make
x = later b, xx = foo b
```

# Reference
[爱编程的大丙](https://subingwen.cn/linux/makefile/)
[makefile详解](https://www.cnblogs.com/paul-617/p/15501875.html)