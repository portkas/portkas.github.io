---
title: coredump
categories:
    - Linux
---
# 什么是coredump

coredump又叫核心转储，是程序崩溃时候的一个内存快照，存储了进程的内存，寄存器状态，运行堆栈等信息。

是一个二进制文件，可以使用以下工具打开分析：

Linux中可以使用：gdb，elfdump，objdump

Windows中可以使用：windebug，solaris下的mdb

<!-- more -->

# 什么时候使用coredump

业务逻辑上的bug，比如参数设置，这种不会导致程序崩溃的错误，使用printf这类输出函数打点调试；

致命操作的bug，比如访问未经申请的内存地址，导致程序崩溃，此时不能使用printf，应该怎么调试呢？

对于必现的bug，一般使用GDB设置断点，逐步执行程序，检查变量和内存，以及回溯调用栈来定位问题。但是对于偶现的bug（多线程竞争，事件相关，资源限制等），由于只在某些特定的条件下发生，所以比较难通过GDB调试，这个时候就可以使用Linux提供的coredump文件进行调试。

# coredump文件生成原理

在程序发生某些错误而导致进程异常退出的时候，Linux内核会根据进程当时的内存信息，生成coredump文件。GDB通过coredump文件可以重现当时的场景，从而定位错误信息。

1. 程序发生错误 -> 产生信号
2. 进程内核检测到对应信号 -> 生成coredump文件

以下信号会导致生成coredump文件：

- SIGILL：非法指令信号
- SIGABRT：由abort()函数发起的信号，用于异常终止程序
- SIGSEGV：无效的内存引用信号，当程序试图访问未分配或不允许访问的内存时
- SIGTRAP：由断点或者某些调试器触发的信号，用于调试目的
- SIGFPE：浮点异常信号，如算术溢出，除以零
- SIGBUG：硬件故障信号，如非法内存访问
- SIGSIS：无效的系统调用信号

当进程从内核态返回到用户态前，内核会检查进程的信号队列中是否有信号没有处理，如果有就调用 `do_signal`内核函数处理信号，流程如下：

![img](../image/coredump.bmp)

## 信号处理do_signal()

```cpp
static void fastcall do_signal(struct pt_regs *regs)
{
    siginfo_t info;
    int signr;
    struct k_sigaction ka;
    sigset_t *oldset;

    ...
    signr = get_signal_to_deliver(&info, &ka, regs, NULL);
    ...
}
```

该函数负责将用户空间的信号传递给进程。其中该函数接收一个指向 `pt_regs`结构的指针作为参数，其中包含了程序计数器、栈指针和所有通用寄存器，这些寄存器在信号处理时被保存。

## 信号获取get_signal_to_deliver()

```cpp
int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
                          struct pt_regs *regs, void *cookie)
{
    sigset_t *mask = &current->blocked;
    int signr = 0;

    ...
    for (;;) {
        ...
        // 1. 从进程信号队列中获取一个信号
        signr = dequeue_signal(current, mask, info); 

        ...
        // 2. 判断是否会生成 coredump 文件的信号
        if (sig_kernel_coredump(signr)) {
            // 3. 调用 do_coredump() 函数生成 coredump 文件
            do_coredump((long)signr, signr, regs);
        }
        ...
    }
    ...
}
```

`get_signal_to_deliver`函数主要完成以下三个工作：

- 调用 `dequeue_signal`函数从进程的信号队列中获取一个信号
- 调用 `sig_kernel_coredump`函数判断信号是否会生成coredump文件
- 如果信号会生成coredump文件，那么就调用 `do_coredump`函数生成coredump文件

## 生成coredump文件

```cpp
int do_coredump(long signr, int exit_code, struct pt_regs *regs)
{
    char corename[CORENAME_MAX_SIZE + 1];
    struct mm_struct *mm = current->mm;
    struct linux_binfmt *binfmt;
    struct inode *inode;
    struct file *file;
    int retval = 0;
    int fsuid = current->fsuid;
    int flag = 0;
    int ispipe = 0;

    binfmt = current->binfmt; // 当前进程所使用的可执行文件格式（如ELF格式）

    ...
    // 1. 判断当前进程可生成的 coredump 文件大小是否受到资源限制
    if (current->signal->rlim[RLIMIT_CORE].rlim_cur < binfmt->min_coredump)
        goto fail_unlock;

    ...
    // 2. 生成 coredump 文件名
    ispipe = format_corename(corename, core_pattern, signr);

    ...
    // 3. 创建 coredump 文件
    file = filp_open(corename, O_CREAT|2|O_NOFOLLOW|O_LARGEFILE|flag, 0600);

    ...
    // 4. 把进程的内存信息写入到 coredump 文件中
    retval = binfmt->core_dump(signr, regs, file);

fail_unlock:
    ...
    return retval;
}
```

`do_coredump`函数主要完成以下四个工作：

- 判断当前进程可生成的coredump文件大小是否收到资源限制
- 如果不受限制调用 `format_corename`生成coredump文件的文件名
- 调用 `filp_open`函数创建coredump文件
- 根据当前进程所使用的可执行文件格式选择相应的方式填充coredump文件的内容
- elf文件格式使用的是 `elf_core_dump`方法

# coredump文件使用-准备阶段

## 生成coredump文件到当前目录下

要让core文件生成在当前目录下，你可以通过设置 `/proc/sys/kernel/core_pattern`文件来指定core文件的保存位置和命名模式。以下是具体的步骤：

1. **开启core文件生成**：
   使用 `ulimit -c unlimited`命令来确保系统允许生成core文件。
2. **设置core文件的命名模式**：
   使用 `echo`命令将core文件的命名模式设置为当前目录下。具体命令如下：

   ```bash
   echo './core-%e-%p-%t' > /proc/sys/kernel/core_pattern
   ```

   这个命令会将core文件统一生成到当前目录下，文件名为 `core-命令名-pid-时间戳`。
3. **参数解释**：

   - `%p`：插入pid到文件名中，即进程ID。
   - `%e`：插入产生core文件的命令名到文件名中。
   - `%t`：插入Unix时间戳到文件名中，即core文件生成时的时间。

执行上述命令后，如果程序再次发生段错误，core文件将会生成在程序运行的当前目录下，并且文件名包含了程序名、进程ID和时间戳，这样你就可以更容易地识别和管理这些core文件了。

需要注意的是，修改 `/proc/sys/kernel/core_pattern`可能需要root权限，如果遇到权限问题，可以尝试使用 `sudo`命令来执行。同时，这些设置是临时的，重启系统后会恢复默认设置。如果需要永久设置，可以修改 `/etc/sysctl.conf`文件并添加相应的配置行，然后运行 `sysctl -p`来使设置生效。

## 设置永久保存

打开/etc/security/limits.conf文件，在该文件的最后加上两行，配置后重启后生效。

```
@root soft core unlimited
@root hard core unlimited
```

命名规则的修改在/proc/sys/kernel/core_pattern中也只是临时的，这个也是动态加载和生成的。永久修改在/etc/sysctl.conf文件中，在该文件的最后加上两行：

```
kernel.core_pattern = ./core-%e-%p-%t
kernel.core_uses_pid = 0
```

可以使用该命令，立即生效：

```bash
$ sudo su
# sysctl –p
# exit
```

## coredump命名规则

```
产生的文件名为core-命令名-pid-时间戳
以下是参数列表:
%p - insert pid into filename 添加pid
%u - insert current uid into filename 添加当前uid
%g - insert current gid into filename 添加当前gid
%s - insert signal that caused the coredump into the filename 添加导致产生core的信号
%t - insert UNIX time that the coredump occurred into filename 添加core文件生成时的unix时间
%h - insert hostname where the coredump happened into filename 添加主机名
%e - insert coredumping executable name into filename 添加命令名
```

## /proc/sys/kernel/core_pattern

/proc/sys/kernel/core_pattern是一个位于/proc伪文件系统中的文件，它用于定义系统在发生核心转储（coredump）时生成的核心文件（corefile）的命名模式和路径。

# 示例1-段错误

```cpp
#include <stdio.h>
  
int func(int *p)
{
    *p = 0;
}
  
int main()
{
    func(NULL);
    return 0;
}
```

编写文件并编译运行：

```bash
$ gcc -g -o app main.c
$ ./app
Segmentation fault (core dumped)
```

文件目录中产生coredump文件：core-app-20132-1733721582，使用coredump文件定位错误信息：

```bash
$ gdb ./app core-app-20132-1733721582
GNU gdb (Ubuntu 12.1-0ubuntu1~22.04.2) 12.1
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./app...
[New LWP 20132]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
--Type <RET> for more, q to quit, c to continue without paging--c
Core was generated by `./app'.
Program terminated with signal SIGSEGV, Segmentation fault.
#0  0x000055902ca68139 in func (p=0x0) at main.c:5
5           *p = 0;
```

可以看到程序是由于 `SIGSEGV`信号产生的coredump文件。接着查看coredump时的堆栈：

```bash
$ bt
or
$ where
(gdb) where
#0  0x000055902ca68139 in func (p=0x0) at main.c:5
#1  0x000055902ca68154 in main () at main.c:10
```

通过 `#0  0x000055902ca68139 in func (p=0x0) at main.c:5`可以定位到是由于 `func (p=0x0)`导致的错误信号。

接着可以使用 `disassemble`打开该帧函数的反汇编代码。

```bash
(gdb) disassemble
Dump of assembler code for function func:
   0x000055902ca68129 <+0>:     endbr64 
   0x000055902ca6812d <+4>:     push   %rbp
   0x000055902ca6812e <+5>:     mov    %rsp,%rbp
   0x000055902ca68131 <+8>:     mov    %rdi,-0x8(%rbp)
   0x000055902ca68135 <+12>:    mov    -0x8(%rbp),%rax
=> 0x000055902ca68139 <+16>:    movl   $0x0,(%rax)
   0x000055902ca6813f <+22>:    nop
   0x000055902ca68140 <+23>:    pop    %rbp
   0x000055902ca68141 <+24>:    ret  
End of assembler dump.
```

如上箭头位置表示coredump时该函数调用所在位置。

接着使用 `info registers` 查看当前寄存器的状态，特别是 `rdi` 寄存器，因为它包含了传递给 `func` 函数的第一个参数。

```bash
(gdb) info registers 
rax            0x0                 0
rbx            0x0                 0
rcx            0x55902ca6adf8      94077712772600
rdx            0x7fff37b64018      140734128078872
rsi            0x7fff37b64008      140734128078856
rdi            0x0                 0
rbp            0x7fff37b63ee0      0x7fff37b63ee0
rsp            0x7fff37b63ee0      0x7fff37b63ee0
r8             0x7fe5c2aadf10      140624790216464
r9             0x7fe5c2acb040      140624790335552
r10            0x7fe5c2ac5908      140624790313224
r11            0x7fe5c2ae0660      140624790423136
r12            0x7fff37b64008      140734128078856
r13            0x55902ca68142      94077712761154
r14            0x55902ca6adf8      94077712772600
r15            0x7fe5c2aff040      140624790548544
rip            0x55902ca68139      0x55902ca68139 <func+16>
eflags         0x10246             [ PF ZF IF RF ]
cs             0x33                51
--Type <RET> for more, q to quit, c to continue without paging--
```

可以看到 `rdi`寄存器指向了一个0地址。接着使用 `x/1x $rax`查看 `rax`寄存器指向的内存地址的内容。

```bash
(gdb) x/1x $rax
0x0:    Cannot access memory at address 0x0
```

由于 `rax` 寄存器存储的是 `NULL`，这将显示一个不可访问的内存区域。


# 寻找this指针和虚指针

```cpp
#include "stdio.h"
#include <iostream>
#include "stdlib.h"
using namespace std;
class base
{
public:
    base();
    virtual void test();
private:
    const char *basePStr;
};
class dumpTest : public base
{
public:
    void test();
private:
    char *childPStr;
};
base::base()
{
    basePStr = "test_info";
}
void base::test()
{
    cout<<basePStr<<endl;
}
void dumpTest::test()
{
    cout<<"dumpTest"<<endl;
    delete childPStr;
}

int main()
{
    dumpTest dump;
    dump.test();
    return 0;
}
```

如上代码实现了一个简单的基类和子类，在main函数里定义了一个子类的实例化对象，并调用他的虚函数方法test，由于test里面没有初始化指针childPStr而直接删除，会造成coredump。

首先编译并运行代码：

```bash
$ g++ -g -o app main.cpp
$ ./app
dumpTest
free(): invalid pointer
Aborted (core dumped)
```

目录列表里产生了coredump文件：core-app-34711-1733723593

接着使用gdb打开coredump文件，同时使用 `bt`打开coredump堆栈信息：

```bash
$ gdb ./app core-app-34711-1733723593
GNU gdb (Ubuntu 12.1-0ubuntu1~22.04.2) 12.1
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./app...
[New LWP 34711]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
Core was generated by `./app'.
Program terminated with signal SIGABRT, Aborted.
#0  __pthread_kill_implementation (no_tid=0, signo=6, threadid=139759220007872)
    at ./nptl/pthread_kill.c:44
44      ./nptl/pthread_kill.c: No such file or directory.


(gdb) bt
#0  __pthread_kill_implementation (no_tid=0, signo=6, threadid=139759220007872)
    at ./nptl/pthread_kill.c:44
#1  __pthread_kill_internal (signo=6, threadid=139759220007872) at ./nptl/pthread_kill.c:78
#2  __GI___pthread_kill (threadid=139759220007872, signo=signo@entry=6)
    at ./nptl/pthread_kill.c:89
#3  0x00007f1c3abe4476 in __GI_raise (sig=sig@entry=6) at ../sysdeps/posix/raise.c:26
#4  0x00007f1c3abca7f3 in __GI_abort () at ./stdlib/abort.c:79
#5  0x00007f1c3ac2b676 in __libc_message (action=action@entry=do_abort, 
    fmt=fmt@entry=0x7f1c3ad7db77 "%s\n") at ../sysdeps/posix/libc_fatal.c:155
#6  0x00007f1c3ac42cfc in malloc_printerr (
    str=str@entry=0x7f1c3ad7b744 "free(): invalid pointer") at ./malloc/malloc.c:5664
#7  0x00007f1c3ac44a44 in _int_free (av=<optimized out>, p=<optimized out>, have_lock=0)
    at ./malloc/malloc.c:4439
#8  0x00007f1c3ac47453 in __GI___libc_free (mem=<optimized out>) at ./malloc/malloc.c:3391
#9  0x0000559355e2f2ab in dumpTest::test (this=0x7ffd2b1ddd50) at main.cpp:31
#10 0x0000559355e2f2e1 in main () at main.cpp:37
```

从堆栈信息可以看到，除了最后两帧，其他的都是libc的代码。

进入到第9帧，并查看堆栈寄存器信息：

```bash
(gdb) info f
Stack level 9, frame at 0x7fff871b7060:
 rip = 0x563d0c5df2ab in dumpTest::test (main.cpp:32); saved rip = 0x563d0c5df2e1
 called by frame at 0x7fff871b7090, caller of frame at 0x7fff871b7040
 source language c++.
 Arglist at 0x7fff871b7050, args: this=0x7fff871b7060
 Locals at 0x7fff871b7050, Previous frame's sp is 0x7fff871b7060
 Saved registers:
  rbp at 0x7fff871b7050, rip at 0x7fff871b7058
```

通过 `this=0x7fff871b7060`可知，this指针指向0x7fff871b7060。

在 C++ 中，对象的内存布局通常如下：

1. 第一个位置是指向虚函数表（vtable）的指针，如果类有虚函数的话。
2. 紧接着是对象的实际数据成员。

虚函数表指针通常存储在对象内存的开始位置，由于this指针指向对象的起始位置，所以可以通过解引用this指针获取虚函数表的地址：

```bash
(gdb) p *(void**)0x7fff871b7060
$2 = (void *) 0x563d0c5e1d38 <vtable for dumpTest+16>
(gdb) x 0x563d0c5e1d38
0x563d0c5e1d38 <_ZTV8dumpTest+16>:      0x0c5df256
(gdb) shell echo _ZTV8dumpTest | c++filt
vtable for dumpTest
```

打印this指针存储的地址，可以看到this指针指向的地址为 `0x563d0c5e1d38`该地址为 `<vtable for dumpTest+16>`即虚函数表偏移16个字节的位置。

```bash
(gdb) x 0x563d0c5e1d38-16
0x563d0c5e1d28 <_ZTV8dumpTest>: 0x00000000
(gdb) x *(void**)0x563d0c5e1d38
0x563d0c5df256 <_ZN8dumpTest4testEv>:   0xfa1e0ff3
(gdb) shell echo _ZN8dumpTest4testEv | c++filt
dumpTest::test()
(gdb) x *(void**)0x563d0c5e1d38-8
0x563d0c5df24e <_ZN4base4testEv+56>:    0xfffffe7e
(gdb) shell echo _ZN4base4testEv | c++filt
base::test()
```

可以看到减去this指针指向的地址减去16字节的偏移量，正好就是虚函数表的地址 `0x563d0c5e1d28`，该内存单元存储的地址为 `0x00000000`。

当使用 `x *(void**)0x563d0c5e1d38`查看该内存地址处的内容时，可以看到存储的内容就是 `dumpTest::test()`；其往前偏移8个字节正好就是 `base::test()`，这也正好说明了，在继承关系中，基类的虚函数在子类虚函数的前面。

在实际问题中，C++程序的很多coredump问题都是和指针相关的，很多segmentfault都是由于指针被误删或者访问空指针、或者越界等造成的，而这些都一般意味着正在访问的对象的this指针可能已经被破坏了，此时，我们通过去寻找函数对应的对象的this指针、虚指针能验证我们的推测。之后再结合代码寻找问题所在。

## 疑惑点解答

`(void**)0x563d0c5e1d38`将地址 `0x563d0c5e1d38` 视为一个指向 `void*` 指针的指针（即 `void**`）,也就是说 `(void**)0x563d0c5e1d38`是一个指向void*类型的指针。*

`*(void**)0x563d0c5e1d38`是对 `void**`类型指针的解引用操作，得到的是一个 `void*`类型的值。这个值可以是一个函数地址，一个对象的地址，或者是虚函数表指针。


# GDB查看core进程的所有线程堆栈

```cpp
#include <iostream>
#include <pthread.h>
#include <unistd.h>
using namespace std;
#define NUM_THREADS 5
int count = 0;

void* say_hello( void *args )
{
    while(1)
    {
        sleep(1);
        cout<<"hello..."<<endl;
        if(1 == count)
        {
            const char *pStr = "hello";
            delete pStr;
        }
    }
}

int main()
{
    pthread_t tids[NUM_THREADS];
    for( int i = 0; i < NUM_THREADS; ++i )
    {
        count = i+1;
        int ret = pthread_create( &tids[i], NULL, say_hello, NULL);
        if( ret != 0 )
        {
            cout << "pthread_create error:error_code=" << ret << endl;
        }
    }

    for( int i = 0; i < NUM_THREADS; ++i )
    {
        count = i+1;
        int ret = pthread_join(tids[i], NULL); 
    }
    pthread_exit(NULL);
}
```

由于代码中在count等于5的时候会delete一个未初始化的指针，所以会生成coredump文件。

首先使用GDB打开coredump文件：

```bash
gdb ./app core-app-178100-1733743589
GNU gdb (Ubuntu 12.1-0ubuntu1~22.04.2) 12.1
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./app...
[New LWP 178101]
[New LWP 178102]
[New LWP 178103]
[New LWP 178100]
[New LWP 178104]
[New LWP 178105]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
--Type <RET> for more, q to quit, c to continue without paging--c
Core was generated by `./app'.
Program terminated with signal SIGSEGV, Segmentation fault.
#0  0x00007f7001fb4449 in arena_for_chunk (ptr=0x55f147223001 <_IO_stdin_used+1>) at ./malloc/arena.c:156
156     ./malloc/arena.c: No such file or directory.
[Current thread is 1 (Thread 0x7f7001e03640 (LWP 178101))]
```

可以看到5个线程的LWP信息。

接着使用 `info threads`查看所有线程正在运行的指令信息：

```bash
(gdb) info threads
  Id   Target Id                          Frame 
* 1    Thread 0x7f7001e03640 (LWP 178101) 0x00007f7001fb4449 in arena_for_chunk (
    ptr=0x55f147223001 <_IO_stdin_used+1>) at ./malloc/arena.c:156
  2    Thread 0x7f7001602640 (LWP 178102) __GI___lll_lock_wake_private (
    futex=0x7f700212ba70 <_IO_stdfile_1_lock>) at ./nptl/lowlevellock.c:57
  3    Thread 0x7f7000e01640 (LWP 178103) futex_wait (private=0, expected=2, 
    futex_word=0x7f700212ba70 <_IO_stdfile_1_lock>) at ../sysdeps/nptl/futex-internal.h:146
  4    Thread 0x7f7001e073c0 (LWP 178100) __futex_abstimed_wait_common64 (private=128, 
    cancel=true, abstime=0x0, op=265, expected=178101, futex_word=0x7f7001e03910)
    at ./nptl/futex-internal.c:57
  5    Thread 0x7f7000600640 (LWP 178104) 0x00007f700202da7b in munmap ()
    at ../sysdeps/unix/syscall-template.S:117
  6    Thread 0x7f6fffdff640 (LWP 178105) futex_wait (private=0, expected=2, 
    futex_word=0x7f700212ba70 <_IO_stdfile_1_lock>) at ../sysdeps/nptl/futex-internal.h:146
```

接着使用 `thread apply all bt`打开所有线程的堆栈信息：

```bash
(gdb) thread apply all bt

Thread 6 (Thread 0x7f6fffdff640 (LWP 178105)):
#0  futex_wait (private=0, expected=2, futex_word=0x7f700212ba70 <_IO_stdfile_1_lock>) at ../sysdeps/nptl/futex-internal.h:146
#1  __GI___lll_lock_wait_private (futex=0x7f700212ba70 <_IO_stdfile_1_lock>) at ./nptl/lowlevellock.c:34
#2  0x00007f7001f8f095 in __GI__IO_fwrite (buf=0x55f147223008, size=1, count=8, fp=0x7f700212a780 <_IO_2_1_stdout_>) at ./libio/iofwrite.c:37
#3  0x00007f7002274b65 in std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long) () from /lib/x86_64-linux-gnu/libstdc++.so.6
#4  0x00007f7002274ebb in std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*) () from /lib/x86_64-linux-gnu/libstdc++.so.6
#5  0x000055f14722229c in say_hello (args=0x0) at main.cpp:13
#6  0x00007f7001fa3ac3 in start_thread (arg=<optimized out>) at ./nptl/pthread_create.c:442
#7  0x00007f7002035850 in clone3 () at ../sysdeps/unix/sysv/linux/x86_64/clone3.S:81

Thread 5 (Thread 0x7f7000600640 (LWP 178104)):
#0  0x00007f700202da7b in munmap () at ../sysdeps/unix/syscall-template.S:117
#1  0x00007f7001fb0cc5 in alloc_new_heap (size=135168, size@entry=2904, top_pad=top_pad@entry=131072, pagesize=pagesize@entry=4096, mmap_flags=mmap_flags@entry=16384) at ./malloc/arena.c:528
#2  0x00007f7001fb116c in new_heap (top_pad=131072, size=2904) at ./malloc/arena.c:576
--Type <RET> for more, q to quit, c to continue without paging--c
#3  _int_new_arena (size=640) at ./malloc/arena.c:744
#4  arena_get2 (size=size@entry=640, avoid_arena=avoid_arena@entry=0x0) at ./malloc/arena.c:963
#5  0x00007f7001fb3a41 in arena_get2 (avoid_arena=0x0, size=640) at ./malloc/arena.c:931
#6  tcache_init () at ./malloc/malloc.c:3244
#7  0x00007f7001fb44cf in tcache_init () at ./malloc/malloc.c:3241
#8  __GI___libc_free (mem=0x55f147223011) at ./malloc/malloc.c:3385
#9  0x000055f1472222da in say_hello (args=0x0) at main.cpp:17
#10 0x00007f7001fa3ac3 in start_thread (arg=<optimized out>) at ./nptl/pthread_create.c:442
#11 0x00007f7002035850 in clone3 () at ../sysdeps/unix/sysv/linux/x86_64/clone3.S:81

Thread 4 (Thread 0x7f7001e073c0 (LWP 178100)):
#0  __futex_abstimed_wait_common64 (private=128, cancel=true, abstime=0x0, op=265, expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:57
#1  __futex_abstimed_wait_common (cancel=true, private=128, abstime=0x0, clockid=0, expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:87
#2  __GI___futex_abstimed_wait_cancelable64 (futex_word=futex_word@entry=0x7f7001e03910, expected=178101, clockid=clockid@entry=0, abstime=abstime@entry=0x0, private=private@entry=128) at ./nptl/futex-internal.c:139
#3  0x00007f7001fa5624 in __pthread_clockjoin_ex (threadid=140119044535872, thread_return=0x0, clockid=0, abstime=0x0, block=<optimized out>) at ./nptl/pthread_join_common.c:105
#4  0x000055f1472223b3 in main () at main.cpp:38

Thread 3 (Thread 0x7f7000e01640 (LWP 178103)):
#0  futex_wait (private=0, expected=2, futex_word=0x7f700212ba70 <_IO_stdfile_1_lock>) at ../sysdeps/nptl/futex-internal.h:146
#1  __GI___lll_lock_wait_private (futex=0x7f700212ba70 <_IO_stdfile_1_lock>) at ./nptl/lowlevellock.c:34
#2  0x00007f7001f96f05 in __GI__IO_putc (c=10, fp=0x7f700212a780 <_IO_2_1_stdout_>) at ./libio/putc.c:30
#3  0x00007f700227426a in std::ostream::put(char) () from /lib/x86_64-linux-gnu/libstdc++.so.6
#4  0x00007f7002274813 in std::basic_ostream<char, std::char_traits<char> >& std::endl<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&) () from /lib/x86_64-linux-gnu/libstdc++.so.6
#5  0x000055f1472222ae in say_hello (args=0x0) at main.cpp:13
#6  0x00007f7001fa3ac3 in start_thread (arg=<optimized out>) at ./nptl/pthread_create.c:442
#7  0x00007f7002035850 in clone3 () at ../sysdeps/unix/sysv/linux/x86_64/clone3.S:81

Thread 2 (Thread 0x7f7001602640 (LWP 178102)):
#0  __GI___lll_lock_wake_private (futex=0x7f700212ba70 <_IO_stdfile_1_lock>) at ./nptl/lowlevellock.c:57
#1  0x00007f7001f8f06d in _IO_acquire_lock_fct (p=<synthetic pointer>) at ./libio/libioP.h:884
#2  __GI__IO_fwrite (buf=<optimized out>, size=1, count=8, fp=0x7f700212a780 <_IO_2_1_stdout_>) at ./libio/iofwrite.c:37
#3  0x00007f7002274b65 in std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long) () from /lib/x86_64-linux-gnu/libstdc++.so.6
#4  0x00007f7002274ebb in std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*) () from /lib/x86_64-linux-gnu/libstdc++.so.6
#5  0x000055f14722229c in say_hello (args=0x0) at main.cpp:13
#6  0x00007f7001fa3ac3 in start_thread (arg=<optimized out>) at ./nptl/pthread_create.c:442
#7  0x00007f7002035850 in clone3 () at ../sysdeps/unix/sysv/linux/x86_64/clone3.S:81

Thread 1 (Thread 0x7f7001e03640 (LWP 178101)):
#0  0x00007f7001fb4449 in arena_for_chunk (ptr=0x55f147223001 <_IO_stdin_used+1>) at ./malloc/arena.c:156
#1  arena_for_chunk (ptr=0x55f147223001 <_IO_stdin_used+1>) at ./malloc/arena.c:160
#2  __GI___libc_free (mem=<optimized out>) at ./malloc/malloc.c:3390
#3  0x000055f1472222da in say_hello (args=0x0) at main.cpp:17
#4  0x00007f7001fa3ac3 in start_thread (arg=<optimized out>) at ./nptl/pthread_create.c:442
#5  0x00007f7002035850 in clone3 () at ../sysdeps/unix/sysv/linux/x86_64/clone3.S:81
```

查看指定线程堆栈信息 `thread apply 4 bt`：

```bash
(gdb) thread apply 4 bt

Thread 4 (Thread 0x7f7001e073c0 (LWP 178100)):
#0  __futex_abstimed_wait_common64 (private=128, cancel=true, abstime=0x0, op=265, expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:57
#1  __futex_abstimed_wait_common (cancel=true, private=128, abstime=0x0, clockid=0, expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:87
#2  __GI___futex_abstimed_wait_cancelable64 (futex_word=futex_word@entry=0x7f7001e03910, expected=178101, clockid=clockid@entry=0, abstime=abstime@entry=0x0, private=private@entry=128) at ./nptl/futex-internal.c:139
#3  0x00007f7001fa5624 in __pthread_clockjoin_ex (threadid=140119044535872, thread_return=0x0, clockid=0, abstime=0x0, block=<optimized out>) at ./nptl/pthread_join_common.c:105
#4  0x000055f1472223b3 in main () at main.cpp:38
```

进入指定线程栈空间：

1. thread n
2. bt
3. i f

```bash
(gdb) thread 4
[Switching to thread 4 (Thread 0x7f7001e073c0 (LWP 178100))]
#0  __futex_abstimed_wait_common64 (private=128, cancel=true, abstime=0x0, op=265, 
    expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:57
57      ./nptl/futex-internal.c: No such file or directory.


(gdb) bt
#0  __futex_abstimed_wait_common64 (private=128, cancel=true, abstime=0x0, op=265, 
    expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:57
#1  __futex_abstimed_wait_common (cancel=true, private=128, abstime=0x0, clockid=0, 
    expected=178101, futex_word=0x7f7001e03910) at ./nptl/futex-internal.c:87
#2  __GI___futex_abstimed_wait_cancelable64 (futex_word=futex_word@entry=0x7f7001e03910, 
    expected=178101, clockid=clockid@entry=0, abstime=abstime@entry=0x0, 
    private=private@entry=128) at ./nptl/futex-internal.c:139
#3  0x00007f7001fa5624 in __pthread_clockjoin_ex (threadid=140119044535872, thread_return=0x0, 
    clockid=0, abstime=0x0, block=<optimized out>) at ./nptl/pthread_join_common.c:105
#4  0x000055f1472223b3 in main () at main.cpp:38


(gdb) i f
Stack level 0, frame at 0x7ffebda6cb90:
 rip = 0x7f7001fa0117 in __futex_abstimed_wait_common64 (./nptl/futex-internal.c:57); 
    saved rip = 0x7f7001fa5624
 inlined into frame 1
 source language c.
 Arglist at unknown address.
 Locals at unknown address, Previous frame's sp in rsp
```

如上即可跳转到指定的线程中，并查看所在线程正在运行的堆栈信息和寄存器信息。


# 学习资源

[coredump文件是如何生成的](https://cloud.tencent.com/developer/article/1860631)
[Linux生成coredump的方法及设置](https://www.cnblogs.com/flyinggod/p/13415862.html)
[gdb调试coredump](https://www.cnblogs.com/lidabo/p/14311900.html)
[gdb调试示例-强烈推荐](https://blog.csdn.net/sunxiaopengsun/article/details/72974548)
[debuginfo](https://developers.redhat.com/articles/2022/01/10/gdb-developers-gnu-debugger-tutorial-part-2-all-about-debuginfo#)【这篇文章有很多不明白的名词，涉及到编译器和DWARF调试信息】
[GDB 入门笔记](https://imageslr.com/2023/gdb.html#coredump)【这是一篇非常全面的GDB入门笔记】
[GDB Documentation](https://sourceware.org/gdb/documentation/)【GDB官方文档】
