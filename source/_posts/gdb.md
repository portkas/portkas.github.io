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

<!-- more -

# g++编译重要参数

- -g 编译带调试信息的可执行文件，选项告诉GCC产生能被GNU调试器——gdb使用的调试信息。
- -O[n] 优化源代码，一般使用-O2。省略掉代码中未使用的变量，将表达式用结果值代替等等。
- -l 和 -L 分别表示指定库文件，指定库路径。库名或者库路径要紧跟在这两个[option]后，中间无空格。
- -I 指定头文件搜索目录
- -Wall 打印警告信息
- -w 关闭警告信息
- -std=c++11 设置编译标准
- -o 指定输出文件名
- -D 定义宏

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

ps.`run`和 `start`在启动gdb之后只能执行其中一个，并只能执行一次。如果遇到断点需要继续执行，输入命令 `continue(c)`

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

| 格式化字符 |     说明     |
| :--------: | :----------: |
|     /x     |   十六进制   |
|     /d     | 有符号十进制 |
|     /u     | 无符号十进制 |
|     /o     |    八进制    |
|     /t     |    二进制    |
|     /f     |    浮点型    |
|     /c     |    字符型    |

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

# 基本命令

## 选择线程: t

`info thread`可以查看当前进程的所有线程。

```bash
(gdb) info threads
  Id   Target Id            Frame 
* 1    process 1537 "example" main () at main.cpp:15
```

`thread/t`可以查看当前位于哪个线程：

```bash
(gdb) t
[Current thread is 1 (process 3496)]
```

在多线程程序里，可以通过 `t {id}`切换线程，每个线程都有独立的调用栈。

## 查看堆栈: bt

`backtrace/bt`可以查看调用栈，调用栈展示了从 `main()`入口到当前断点的所有函数调用路径：

```bash
(gdb) bt
#0  0x0 in (unknown) at :0
#1  0x1a796e7c in foo() at main.cpp:13
#2  0x6259058 in bar() at main.cpp:17
#3  0x6bb7580 in main() at main.cpp:83
```

## 选择栈帧: f

每次函数调用，都会创建一个独立的栈帧，对应上面的 `#0`,`#1`...，默认在 `#0`

`frame/f`可以跳转到指定栈帧：

```bash
(gdb) f 2
#2  bar() at main.cpp:17
17        int a = foo();
```

`up/down`可以向下层或上层跳转，对应编号的增大或减小。

## 打印变量: p

### 基本使用

`print/p`可以打印一个变量值：数字，字符串，结构体，指针等变量类型

```bash
(gdb) p a // int a = 3;
$1 = 3
```

打印出来的值会存在名为 `$1`,`$2`...的变量里，后续可以直接复用：

```bash
(gdb) p $1 // 等价于 p a
$2 = 3
```

### 打印指针

p后面直接跟一个指针类型的变量，打印的是指针的值，即指针所指向的地址：

```bash
(gdb) p b // int* b = &a;
$1 = (int *) 0x7ffd3dcfa27c
```

可以用解引用运算符，打印指针指向的值：

```bash
(gdb) p *b
$2 = 1
```

如果是字符串指针，p会同时输出指针指向的地址和字符串的内容：

```bash
p str
$3 = (char*) 0x7ffc734ff250 "hello,world"
```

如果只希望打印指针，可以使用说明符 `/a`:

```bash
(gdb) p/a str	// /a表示address即把变量以地址的形式打印
$4 = 0x7ffc734ff250
```

#### 地址字面量

p默认会把十六进制的字面量看成是数字，输出一个十进制的整数：

```bash
(gdb) p 0x7ffd3dcfa27c
$1 = 140725640471164
(gdb) p 140725640471164 == 0x7ffd3dcfa27c
$2 = true
```

如果想把数字解释为地址，打印地址上的内容，需要先指定变量类型，然后解引用：

```bash
(gdb) p *(int*)0x7ffd3dcfa27c
$3 = 1
```

更简单的语法是：`{TYPE} ADDRESS`

```bash
(gdb) p {int}0x7ffd3dcfa27c
$4 = 1
```

#### 转换指针类型

指针的类型可以转换，以不同的方式解释其指向的内存区域：

```bash
// char* c = "hello, world";
(gdb) p c
$1 = (char *) 0x7ffc734ff250 "hello, world";
(gdb) p *(int*)c
$2 = 1819043176
(gdb) p {int}c
$3 = 1819043176
```

打印内存可以发现，`1819043176`就是把hell四个字符解释成了一个整数：

```bash
(gdb) x/w 0x7ffc734ff250    // 以 word 形式打印，4 个字节
0x7ffc734ff250:	1819043176  // 上述 4 个字符的 ASCII 码转成整数
```

`1819043176` 对应的十六进制是 `0x6C6C6568`，恰好依次是 `l` , `l` , `e` 和 `h` 的 ASCII 码。

#### 打印结构体字段

如果指针 `p` 指向某个结构体，可以用 `p ptr->field` 打印字段的值。

在 GDB 里 `.` 和 `->` 是一样的，所以无论 `ptr` 是否是指针，都可以用 `p.field` 打印字段的值。

### 打印数组

语法：`p ELEMENT@LEN`。从ELEMENT的地址开始向后解释LEN大小的内存单元

#### 栈上数组

如果array是栈上数组，直接p array会打印数组的所有元素。

```bash
// int array[] = {1, 2, 3, 4};
(gdb) p array
$1 = {1, 2, 3, 4}
```

也可以 `p array[INDEX]@LEN`，从某个下标开始打印指定的长度：

```bash
(gdb) p array[1]@3
$4 = {2, 3, 4}
```

但是不能 `p array@3`，因为栈上数组array的类型是int[4]而不是int：

```bash
(gdb) p array@3
$6 = {{1, 2, 3, 4}, {4096, 0, 89129472, 1043493597}, {1, 0, -136626800, 32767}}
```

#### 堆上数组

如果array是堆上数组，可以使用：`p *array@LEN`：

```bash
// int* array = (int*)malloc(3 * sizeof(int));
(gdb) p *array@3 // *array 是数组的第一个元素，类型是 int
$1 = {1, 2, 3}
```

或者 `p array[INDEX]@LEN`，从某个下标开始打印：

```bash
(gdb) p array[1]@3 // array[1] 的类型是 int
$2 = {2, 3, 4}
```

但是不能 `p array`，因为堆上数组array的类型是int*指针，值是一个地址：

```bash
(gdb) p array
$3 = 0x55669a743eb0
```

同理，`p array@LEN`会输出栈上相邻的内存地址（没有意义）：

```
(gdb) p array@3
$4 = {0x55669a743eb0, 0x55669a255330, 0x200000001}
```

如果数组只有一个地址字面量，可以把它强制转换为指针类型，然后用同样的语法打印：

```bash
(gdb) p ((int*)0x55669a743eb0))[2]
$5 = 3
```

### 格式化输出

可以在p后面添加说明符，把一个变量解释为给定的类型：

```bash
(gdb) p foo // int foo = 98;
$1 = 98
(gdb) p/c foo // 将 98 解释为字符
$2 = 98 'b'
```

所有说明符：

- p/a：将变量解释为指针address，使用十六进制打印
- p/c：将变量解释为字符，打印为字符
- p/o：使用八进制打印变量
- p/x：使用十六进制打印变量
- p/u：将变量解释为无符号整数unsigned，使用十进制打印
- p/s：将变量解释为字符串打印输出
- help x：查看全部

```plaintext
o(octal), x(hex), d(decimal), u(unsigned decimal),
t(binary), f(float), a(address), i(instruction), 
c(char), s(string) and z(hex, zero padded on the left)
```

### STL容器

#### std::shared_ptr

直接打印：

```bash
// std::shared_ptr<int> ptr = std::make_shared<int>(1);
(gdb) p ptr
$1 = std::shared_ptr<int> (use count 1, weak count 0) = {
  get() = 0x5596169122f0}
(gdb) p *ptr
$2 = 1
```

或者根据上面get()方法给出的地址打印：

```bash
(gdb) p {int}0x5596169122f0
$3 = 1
```

或者根据shared_ptr内部的私有变量 `_M_ptr`打印：

```bash
(gdb) p ptr._M_ptr
$4 = 0x5596169122f0
(gdb) p *(ptr._M_ptr)
$5 = 1
```

#### std::vector

直接打印：

```bash
// std::vector<int> vec = {1, 2, 3, 4};
(gdb) p vec
$1 = std::vector of length 4, capacity 4 = {1, 2, 3, 4}
```

vector也有私有变量，保存了数据的实际存储位置：

- `_M_imp1._M_start`：数组起始地址
- `_M_imp1._M_finish`：数组结束地址（数组最后一个元素的下一个）

可以根据这个指针打印：

```bash
(gdb) p {int}vec._M_impl._M_start
$2 = 1
(gdb) p {int}vec._M_impl._M_start@3
$3 = {1, 2, 3}
(gdb) p ({int}vec._M_impl._M_start)[2]
$4 = 3
```

#### std::string

直接打印：

```bash
(gdb) p str
$1 = "hello,world"
```

或者根据私有变量 `_M_dataplus._M_p`打印，其类型是char*：

```bash
(gdb) p str._M_dataplus._M_p
$2 = (std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::pointer) 0x7ffc734ff250 "hello,world"
```

#### 使用STL-Views插件

使用gdb打印set，stack，map等STL容器比较困难。gdb支持使用python编写的printer，[GDB官网](https://sourceware.org/gdb/wiki/STLSupport)提供了STL容器的printer。

1. [下载地址](https://sourceware.org/gdb/wiki/STLSupport?action=AttachFile&do=view&target=stl-views-1.0.3.gdb)
2. [官方教程](http://www.yolinux.com/TUTORIALS/GDB-Commands.html#STLDEREF)
3. 把下载下来的文件放到home目录（wherever）
4. 进入gdb
5. 加载插件：source ~/std-views-1.0.3.gdb

进入gdb，加载插件，查看帮助：

```bash
(gdb) source ~/stl-views-1.0.3.gdb
(gdb) help pset
(gdb) help pmap
```

使用：

```bash
(gdb) pset s
(gdb) pset s int
(gdb) pset s int 20
```

### 如果打印内容被省略

打印字符串的时候，如果有重复的字符，可能会被合并成一个：

```bash
(gdb) p "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$1 = 'a' <repeats 30 times>
```

可以通过命令 `set print repeats 0`设置为不合并：

```bash
(gdb) set print repeats 0
(gdb) p "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
$2 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
```

如果打印数组的时候元素过多，中间的元素会被省略，可以通过以下设置，设置为不省略：

```bash
set print elements 0
```

### 查看历史变量

通过p打印出来的值，会被存在名为$1,$2,$3...的变量里（[value history](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Value-History.html#Value-History)）后续可以直接复用：

```bash
(gdb) p a
$1 = 123
(gdb) p $1 // 等价于 p a
$2 = 123
```

一些特殊的变量：

- `$`：最近打印的变量
- `$$`：`$`之前的变量，即倒数第二个
- `$$n`：最后一个变量往前的第n个变量比如 `$$0`就是 `$`

可以批量打印历史变量：

- `show value`：打印最后10个历史变量
- `show value +`：这个命令是在 `show value`的基础上使用的，它会打印出紧随刚才 `show value`命令打印的10个历史变量之后的另外10个历史变量。这个命令用于当你想要查看更多历史变量时，而不仅仅是最近的10个。

## 打印内存: x

x可以查看一个内存地址的值，以指定的格式打印。

```bash
(gdb) x/s 0x7ffc734ff250  // 以字符串形式打印
0x7ffc734ff250:	"hello,world"
```

x支持的格式化说明符：

- x/c：将地址解释为字符char，打印为字符
- x/o：使用八进制打印变量
- x/x：使用十六进制打印变量
- x/u：将地址解释为无符号整数unsiged，使用十进制打印
- x/s：将地址解释为字符串
- help x：查看全部

x的完整语法：`x/FMT ADDRESS`，`F` / `M` / `T` 是可选的参数。

* `F`：一个数字，表示输出几个内存单元，默认是 1
* `M`：格式化说明符，`o` / `x` / `d` / `u` / `s` 等
* `T`：一个内存单元的字节数，默认是 4 个字节，可选的是 b(byte), h(halfword), w(word), g(giant, 8 bytes)
* `ADDRESS`：一个内存地址，可以是一个字面量，也可以是一个指针类型的变量

> 例如，`x/3uh 0x1234` 表示从内存地址 0x1234 开始，以两字节为单位，输出 3 个无符号整数。

### x和p的区别：

1. 传入一个数字，p会当作一个数字字面量，输出原始值得十进制；而x会当作一个地址，输出对应内存区域得值：

   ```bash
   (gdb) p 0x10    // 字面量
   $1 = 16  	      // 输出十进制值
   (gdb) p/x 0x10  // 以十六进制形式输出
   $2 = 0x10

   (gdb) x/s 0x10  // 这个内存地址解释为字符串
   0x10 "hello, world"  
   (gdb) x/c 0x10  // 把这个地址上的内容解释为单个字符
   0x10:	'h'
   (gdb) x/d 0x10  // 把这个地址上的内容解释为整数
   0x10:	104
   ```
2. 传入一个指针，p会输出指针的值，即一个十六进制的地址；而x会输出指针指向的内存区域的值：

   ```bash
   （gdb) p str_pointer;
   $1 = 0x7ffc

   (gdb) x/s 0x7ffc
   0x7ffc "hello world"
   ```

## 打印类型: ptype

```bash
(gdb) ptype foo
type = int
```

## 打印各种信息: i

- `info locals`打印当前栈帧的局部变量
- `info args`：打印所有函数参数
- `info threads`：打印进程的线程信息
- `info registers`：打印当前线程的寄存器信息
- `info sharedlibrary`：打印当前加载的动态链接库
- `info proc mappings`：打印地址空间中的内存map，用来确定某个地址的类型
- `help info`：所有info支持的命令

## 存储变量/修改变量的值: set

set可以保存一个变量（[Convenience Variables](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Convenience-Vars.html)）方便后续使用：

```bash
（gdb) set $foo = *object_ptr
```

查看所有存储的变量：

```bash
(gdb) show convenience
(gdb) show conv  // 简写形式
```

set命令可以用于在运行时修改某个变量的值：

```bash
(gdb) set foo.bar = true
```

修改变量值的使用场景：

- 临时修复某个bug使程序可以继续运行
- 给变量设置不同的值，测试不同的case
- 循环中设置循环变量的值，直接快进到最后一轮查看结果

## 断点调试: b

### 设置断点

设置断点的方式有多种（[官方文档](https://ftp.gnu.org/old-gnu/Manuals/gdb/html_node/gdb_28.html)）:

- 在当前执行位置设置断点：`b`
- 函数名：`b function`
- 文件名+函数名：`b filename:function`
- 当前文件行号：`b linenum`
- 特定文件行号：`b filename:linenum`
- 偏移量：`b +offset`/`b -offset`，在当前栈帧执行位置的前后设置断点

### 删除断点: clear

```bash
(gdb) clear foo.cpp:14
```

clear的语法和break相同，需要指定要删除的断点的位置：

- clear：删除当前指定位置上的所有断点
- clear function
- clear filename:function
- clear linenum
- clear filename:linenum
- delete：删除所有断点，简写d

设置临时断点：tbreak，参数同break，命中一次后自动删除

### 启用/停用断点

停用断点：`disable`

启用断点：`enable`

```bash
停用断点：disable

(gdb) disable      // 停用所有断点
(gdb) disable NUM  // 停用编号为 n 的断点
```

### 继续运行: c

命中断点之后程序会停止运行，此时可以通过 `continue`命令继续运行程序，简写 `c`

### 查看所有断点: i b

```bash
(gdb) i b
(gdb) info breakpoints
```

会以表格的形式展示断点编号，是否是临时断点，是否enable，断点位置等信息。

### 在函数返回前中断

有时候希望在函数返回前中断，从而检查函数的返回值，或者检查函数是在哪一个 `return`语句返回的。

1. 方式一：先正向执行直到函数返回，然后再反向执行设置断点：

   ```bash
   (gdb) record
   (gdb) fin
   (gdb) reverse-step
   ```

   record：这个命令用于开启GDB的记录功能。当你执行 `record`命令后，GDB会开始记录程序的执行历史，包括函数调用、变量值的变化等。

   fin：这个命令用于结束当前的记录会话。在执行完 `record`命令并让程序运行到你想要检查的函数返回之后，使用 `fin`命令来停止记录。

   reverse-step：这个命令用于执行反向单步执行。在停止记录后，你可以使用 `reverse-step`命令来反向步进，检查函数返回前的状态。
2. 方式二：所有函数无论有多少条return语句，在编译成汇编指令后，一定是只有一条 `retq`指令，因此可以在汇编指令中找到 `retq`所在位置打断点：

   ```bash
   int main() {
     return foo(0);
   }

   (gdb) disas foo  // 查看汇编
   Dump of assembler code for function foo:
      0x0000000000400448 <+0>: push   %rbp
      0x0000000000400449 <+1>: mov    %rsp,%rbp
      ...
      0x0000000000400473 <+43>:    jmp    0x40047c <foo+52>
      0x0000000000400480 <+56>:    retq   // 这里就是函数的返回指令
   End of assembler dump.

   (gdb) b *0x0000000000400480  // 在 retq 指令打断点
   Breakpoint 1 at 0x400480

   (gdb) r  // 运行程序，直到命中断点
   Breakpoint 1, 0x0000000000400480 in foo ()

   (gdb) p var
   $1 = 42
   ```

### 监控断点: watch

GDB可以监控一个变量，直到它被修改时才触发断点，[官方文档](https://ftp.gnu.org/old-gnu/Manuals/gdb/html_node/gdb_29.html#SEC30)：

```bash
(gdb) watch foo
(gdb) watch bar.var
```

如果想在变量被读取时中断，可以使用 `rwatch` 或 `awatch`：

- rwatch：仅当变量被读取时中断
- awatch：当变量被读取或写入时中断

查看所有的watchpoints:

```bash
(gdb) info watchpoints
```

### 条件断点: b...if

常规断点（breakpoints）和监控断点（watchpoints）都可以绑定一个条件，只有在满足条件时才触发断点，[官方文档](https://ftp.gnu.org/old-gnu/Manuals/gdb/html_node/gdb_33.html#SEC34)：

“条件”是一个布尔表达式：

```bash
(gdb) b foo.cpp:123 if bar == 1
(gdb) b foo.cpp:123 if bar == 1 && foo < 2
```

如果要判断两个字符串是否相等，可以使用gdb的内置函数 `$_streu`

```bash
(gdb) b foo.cpp:123 if $_streq(some_str, "hello_world")
```

### 断点命令列表: commands

可以通过commands命令给断点绑定一组自定义命令，当命中断点后会自动执行，打印变量的值，或者设置另一个断点。

语法：先制定要绑定的断点的编号，然后输入自定义命令，最后以end结束：

```bash
（gdb) commands 1
（gdb) p foo
（gdb) end
```

断点编号可以通过 `i b`或者 `i wat` 获取，如果不给commands传入任何编号，默认绑定到最近触发的断点上。

`commands`的应用场景之一是收集信息。比如在某行代码后面插入一行debug日志，打印变量或者调用栈。由于每次命中断点后，必须输入 `cont`命令才会继续运行程序，因此可以在 `end`前加一个 `cont`命令，这样程序就可以无需干预自动执行：

```bash
(gdb) b foo.cpp:123
(gdb) commands
(gdb) p bar
(gdb) cont
(gdb) end
```

`commands`的另一个应用场景是临时修复一个bug，以便让程序正常运行。比如在某一行错误代码后面，给变量设置正确的值。

```bash
(gdb) b foo.cpp:123
(gdb) commands
(gdb) silent  // 这个命令后面的命令不会有任何输出
(gdb) set x = y + 4
(gdb) cont
(gdb) end
```

## 运行程序: n/s/n/fin/u

- run/r：启动程序，直到遇到第一个断点或运行结束
- start：启动程序，临时停在main()的第一行
- next/n：逐行执行，如果某一行是函数，不会进入函数内部，而是执行完整个函数
- step/s：逐行执行，如果某一行是函数，则会进入函数的第一行
- continue/c：从断点位置继续执行，直到遇到下一个断点或运行结束
- finish/fin：执行到函数结束，停在return后的下一条语句
- until/u
  - 不加任何参数：执行直到当前语句结束，比如在for循环里，until会跳到for循环体的下一行，准备开始下一次迭代。这样，你可以逐个检查循环的每次迭代，而不需要每次都手动继续执行。
  - 加参数：执行直到指定位置，参数语法同break，等价于tbreak+continue
- quit/q：退出GDB

直接回车会重复上一次执行的命令。

## 输出日志: set logging

可以把所有输出打印到日志里，作进一步分析。

需要执行以下两个命令：

```bash
(gdb) set logging file gdb.txt
(gdb) set logging on
copying output to gdb.txt
```

这样任何命令的输出便会写到 `gdb.txt`文件中，前提是shell拥有该文件的写入权限。

配合以下命令，确保输出完整内容：

```bash
set print repeats 0       // 否则相同的连续字符会被合并
set print elements 0      // 否则过长的数组会被省略
set height 0              // 否则如果一页显示不完，会停下来要求 continue
set width 0  
```

# 配置文件: ~/.gdbinit

可以把一些常用的配置、插件、自定义命令放在 `~/.gdbinit`

Github 上有一些开箱即用的 `~/.gdbinit` 文件：

* [https://github.com/gdbinit/Gdbinit/blob/master/gdbinit](https://github.com/gdbinit/Gdbinit/blob/master/gdbinit)
* [gdb-dashboard](https://github.com/cyrus-and/gdb-dashboard)：可视化界面、丰富的功能
* [gef](https://github.com/hugsy/gef)：可视化界面、丰富的功能
* [pwndbg](https://github.com/pwndbg/pwndbg)

gdb-dashboard 使用笔记：

* 使用 `-output` 命令将某些组件在其他终端显示，比如终端 A 执行 gdb 命令，终端 B 显示断点、变量值、调用栈。在终端输入 `tty` 命令就可以查看当前终端的序号。
* 介绍文章：[https://zhuanlan.zhihu.com/p/435918702](https://zhuanlan.zhihu.com/p/435918702)


# 加载插件

GDB 可以使用 [Python API](https://sourceware.org/gdb/onlinedocs/gdb/Python-API.html) 来实现自定义脚本。脚本可以直接写在 `~/.gdbinit`，或者写在一个单独的文件中，然后通过 `source` 命令加载。

网上有很多可用的插件，比如 [STL views](https://sourceware.org/gdb/wiki/STLSupport) 提供了一些打印 STL 容器的命令。


# 术语

## 栈帧

调用栈（call stack）被分成若干个栈帧（stack frame），每个栈帧包括一次函数调用相关的所有数据：函数的参数，函数的局部变量，函数的返回地址等。

程序启动时只有一个栈帧即main函数，又称初始栈帧或最外层栈帧。每次函数调用都会创建一个新栈帧，每次函数返回时，一个栈帧也会被弹出。当前执行的函数所对应的栈帧又称最内层栈帧。

GDB给每个栈帧分配了一个数字，最内层栈帧的编号为0，外层栈帧一次加1。可以通过 `bt`命令查看所有栈帧，通过 `f`命令加上编号进入到对应的栈帧。


# 学习资源

- [GDB官网](https://sourceware.org/gdb/)
- [Debugging with GDB](https://sourceware.org/gdb/onlinedocs/gdb/)
- [gdb debug full examples](https://www.brendangregg.com/blog/2016-08-09/gdb-example-ncurses.html)
- [100个 GDB 小技巧](https://wizardforcel.gitbooks.io/100-gdb-tips/content/index.html)
- [在线 GDB 平台](https://pernos.co/)
- [GDB 入门](https://imageslr.com/2023/gdb.html#coredump)
