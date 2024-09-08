---
title: gdb
categories:
    - Linux
---
# 开始
编译程序的时候：
1.打开编译选项（-g）
2.关掉编译器优化选项（-O0）
3.打开所有的warning（-Wall）
<!-- more -->

# 启动和退出gdb
## 启动gdb
```bash
# 语法：gdb 可执行程序
$ gdb main
```

## gdb中命令行传参（set args）
```bash
# 启动gdb之后
# 语法：set args 参数1 参数2 ...
# 通过gdb给应用程序设置命令行参数
(gdb) set args 1 2 3

# 查看设置的命令行参数
(gdb) show args
```

## gdb中启动程序（run/start）
* run（r）：如果程序设置了断点，会停在断点的位置，如果没有设置断点，程序执行到结束。
* start：启动程序，程序运行到main函数的第一行。

ps.`run`和`start`在启动gdb之后只能执行其中一个，并只能执行一次。如果遇到断点需要继续执行，输入命令`continue(c)`

## 退出gdb（quit）
```
(gdb) quit
or
(gdb) q
```

# 查看代码（list）
## 在当前文件下查看代码
通过list查看代码，每次只显示10行，如果需要继续查看后面的代码，直接按回车（即再次执行list指令）
```
# 从第一行开始显示
(gdb) list

# 显示第n行的上下文
(gdb) list n

# 显示某个函数的上下文
(gdb) list <function-name>
```

## 显示其他文件下的代码
```
# 切换到指定的文件，并列出第n行对应的上下文
(gdb) list <filename>:n

# 切换到指定的文件，并列出函数的上下文
(gdb) list <filename>:<function-name>
```

## 设置显示的行数
```
# 设置每次显示的行数
(gdb) set listsize 行数

# 查看当前list一次能显示的行数
(gdb) show listsize
```

# 断点
## 设置断点（break）
* 常规断点
* 条件断点

```
# 在当前文件下设置断点
(gdb) b <n>
(gdb) b <function-name>

# 在其他文件上设置断点（比如当前在PC指针在main.c文件下，但是想在sub.c中设置断点）
(gdb) b <filename>:n
(gdb) b <filename>:<function-name>
```

```
# 条件断点：只有满足某个条件后程序才会停在这个断点的位置上
(gdb) b <n> if 变量名==某个值
```

## 查看断点（info）
```
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000400cb5 in main() at test.cpp:12
```
* Num：断点的编号
* Enb：断点的状态，y表示使能，n表示未使能
* What：断点所在文件，函数，行数

## 删除断点（delete）
```
# 删除一个断点
(gdb) d 断点编号

# 删除断点1,2,3
(gdb) d 1 2 3

# 删除一个范围的断点
(gdb) d 断点编号1-断点编号N

# 删除编号1到编号5的所有断点
(gdb) d 1-5
```

## 设置断点状态（enable/disable）
```
# 设置断点无效
(gdb) disable 断点编号

# 设置断点有效
(gdb) enable 断点编号
```

# 调试
## 继续运行（continue）
遇到断点，程序停止，可以执行c指令继续向下运行，直到遇到下一个断点。
```
(gdb) continue
```

## 手动打印信息
### 打印变量值（print）
|格式化字符|说明|
|:---:|:---:|
|/x|十六进制|
|/d|有符号十进制|
|/u|无符号十进制|
|/o|八进制|
|/t|二进制|
|/f|浮点型|
|/c|字符型|
```
(gdb) p 变量名
# 以16进制打印变量i
(gdb) p/x i
```

### 打印变量类型（ptype）
```
(gdb) ptype 变量名
# 打印数组array的类型
(gdb) ptype array
type = int[12]
```

## 查看内存（x）
```
x <addr>

# 查看函数fun的地址,以16进制输出
(gdb) x/x fun
```

## 自动打印信息
### 设置某些变量自动打印变量值(display)
```
(gdb) display 变量名

# 以16进制自动显示变量i的值
(gdb) display/x i
```

### 查看自动显示列表(info display)
```
(gdb) info display
Auto-display expressions now in effect:
Num Enb Expression
2:   y  array[i]
```
* Num：变量/表达式的编号（唯一）。
* Enb：y表示激活状态，n表示禁用状态
* Expression：变量/表达式的名字

### 取消自动显示(undisplay)
```
# 删除自动显示列表中的变量或表达式
(gdb) undisplay 编号

# 禁用某个变量自动显示
(gdb) disable display 编号

# 激活某个变量自动显示
(gdb) enable display 编号
```

## 单步调试
### step（s）
命令被执行一次，代码向下运行一行，如果有函数，则会进入函数体内部。

### finish
通过s单步调试进入函数体内部，如果想要跳出函数体，执行该命令。但是需要保证函数体内不能有有效断点，否则无法跳出。

### next
命令被执行一次，代码向下运行一行，不会进入函数体内部。

### until
通过until命令跳出循环体，需要满足以下条件：
* 要跳出的函数体内部不能有有效的断点
* 必须要在循环体的开始/结束行执行该命令

## 设置变量值
在循环体中，如果循环比较久，可以直接设置变量到最后两次循环，然后单步运行查看运行结果。
```
(gdb) set var 变量名=值
# 在100次的循环体中设置变量i为99
(gdb) set var i=99
```