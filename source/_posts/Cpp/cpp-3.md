---
title: cpp-3-内存模型
categories:
	- cpp
---
* 单独编译
* 存储持续性，作用域和链接性
* 定位new运算符
* 名称空间

<!-- more -->

# 单独编译

1. 通常大型程序由多个源代码文件组成，这些文件可能共享一些数据，这样的程序涉及到文件的单独编译。

* 头文件：包含结构声明和使用这些结构的函数的原型；
* 源代码文件：包含与结构有关的函数的代码；
* 源代码文件：包含调用与结构有关的函数的代码；

2. 禁止将函数定义或变量声明放到头文件中：如果在头文件包含一个函数定义，然后在其他两个文件中包含该头文件，则同一个程序中将包含同一个函数的两个定义，除非函数是内联的，否则会报错重复定义；
3. 头文件通常包含的内容：

- 函数原型
- 使用#define或const定义的符号常量
- 结构声明
- 类声明
- 模板声明
- 内联函数

4. 将结构声明放在头文件中是可以的，因为它们不创建变量；
5. 在同一个文件中只能将同一个头文件包含一次；

```cpp
#ifndef HEAD_H_
#include "head.h"
#endif
```

6. 多个库的链接：在链接编译模块的时候，确保所有对象文件或库是由同一个编译器生成的，避免链接错误。

# 存储持续性，作用域和链接性

C++使用三种（在C++11中是四种)不同的方案来存储数据，这些方案的区别在于数据保留在内存中的时间：

- 自动存储持续性：在函数定义中声明的变量（包括函数参数)的存储持续性为自动的。它们在程序开始执行其所属的函数或代码块时被创建，在执行完函数或代码块时，他们使用的内存被释放；
- 静态存储持续性：在函数定义外定义的变量和使用关键字static定义的变量的存储持续性为静态。它们在程序整个运行过程中都存在；
- 线程存储持续性（C++11)：在多核处理器中很常见，如果变量是使用thread_local声明的，则其生命周期与所属的线程一样长；
- 动态存储持续性：用new运算符分配的内存将一直存在，直到delete运算符将其释放或程序结束为止。这种内存的存储持续性为动态，有时被称为自由存储或堆；

### 作用域和链接

链接性：描述了名称如何在不同单元间共享，链接性为外部的名称可以在文件间共享，链接性为内部的名称只能由一个文件中的函数共享，自动变量的名称没有链接性，因为他们不能共享；

C++函数的作用于可以是整个类或整个名称空间，但不能是局部的（因为它们不能在代码块内定义函数)；

### 寄存器变量

在C++中，`register`关键字用于建议编译器将变量存储在寄存器中，以提高变量访问的速度。然而，这只是对编译器的一个提示，编译器可以忽略这个关键字。使用 `register`关键字的变量通常用于频繁访问的变量，以减少内存访问的开销。

使用示例：

```cpp
#include <iostream>

int main() {
    register int counter = 0;

    for (counter = 0; counter < 10; ++counter) {
        std::cout << "Counter: " << counter << std::endl;
    }

    return 0;
}
```

在这个例子中，`counter`变量被声明为寄存器变量，这意味着编译器会尝试将其存储在寄存器中，以便在循环中快速访问和修改.

注意事项：

1. **作用域限制**：`register`变量必须是局部变量，不能是全局变量或静态变量.
2. **存储限制**：由于寄存器的数量有限，编译器可能会根据实际情况选择是否将变量存储在寄存器中.
3. **C++11及以后**：在C++11标准中，`register`关键字被标记为弃用（deprecated），但仍然可以使用。C++17标准中，`register`关键字被正式移除。因此，在现代C++代码中，建议避免使用 `register`关键字，而是依赖编译器的优化能力来决定变量的存储位置.

现代编译器通常具有高度优化的能力，能够自动识别并优化频繁访问的变量，因此在大多数情况下，显式使用 `register`关键字并不会带来显著的性能提升。

关键字register用于在声明中指示寄存器存储，而在C++11中，它只是显式地指出变量是自动的。

### 静态持续变量

C++为静态存储持续性变量提供了三种链接性：

- 外部链接性（可在其他文件中访问)
- 内部链接性（只能在当前文件中访问)
- 无链接性（只能在当前函数或代码块中访问)

这三种链接性在整个程序执行期间都存在，与自动变量相比，他们的寿命更长。静态变量的数目在程序运行期间是不变的，编译器将分配固定的内存块来存储所有的静态变量；

- 要创建链接性为外部的静态持续变量，必须在代码块的外面声明它；
- 要创建链接性为内部的静态持续变量，必须在代码块的外面声明它，并使用static限定符；
- 要创建没有链接性的静态持续变量，必须在代码块的内部声明它，并使用static限定符；

```cpp
// 外部链接性静态持续变量
int global = 1000;

// 内部链接性静态持续变量
static int one_file = 50;

// 无链接性静态持续变量
void func(){
   static int count = 0;
}
```

所有的静态持续变量在整个程序执行期间都存在。在func()中声明的变量count的作用于为局部，没有链接性，这意味着只能在func()函数中使用它，但是与自动变量不同的是，即使在func()函数没有被执行时，count也留在内存中，并且其只会被初始化一次，具有记忆性；

globle和one_file变量的作用于都为整个文件，即从声明位置到文件结尾的范围内都可以被使用，由于one_file的链接性为内部，因此只能在包含该变量的单个文件中使用；由于global的链接性为外部，因此可以在程序的其他文件中使用它。

### 静态持续性，外部链接性

#### 单定义规则

一方面，在每个使用外部变量的文件中都必须声明它；另一方面，C++中有单定义原则，即变量只能有一次定义。为了满足这种需求，C++中有两种变量声明方式：

- 定义声明：给变量分配存储空间
- 引用声明（extern)：不给变量分配存储空间，引用已有的变量

引用声明使用关键字extern且不进行初始化，如果初始化的话声明为定义，会导致分配空间；

如果要在多个文件中使用外部变量，只需要在一个文件中包含该变量的定义（单定义规则)，但在使用该变量的其他所有文件中，都必须使用关键字extern声明它；

```cpp
// external.cpp -- external variable
// compile with support.cpp
#include <iostream>
// external variable
extern double warming = 0.3;       // warming defined

// function prototypes
void update(double dt);
void local();

int main()                  // uses global variable
{
    using namespace std;
    cout << "Global warming is " << warming << " degrees.\n";
    update(0.1);            // call function to change warming
    cout << "Global warming is " << warming << " degrees.\n";
    local();                // call function with local warming
    cout << "Global warming is " << warming << " degrees.\n";
    // cin.get();
    return 0;
}
```

这里在定义声明的时候使用了extern关键字（错误的行为)，编译器会给出警告：

```bash
[ 33%] Building CXX object CMakeFiles/app.dir/external.cpp.o
/home/zhm/Desktop/test/extern/external.cpp:5:15: warning: ‘warming’ initialized and declared ‘extern’
    5 | extern double warming = 0.3;       // warming defined
      |               ^~~~~~~
[ 66%] Building CXX object CMakeFiles/app.dir/support.cpp.o
[100%] Linking CXX executable /home/zhm/Desktop/test/extern/bin/app
[100%] Built target app
```

```cpp
// support.cpp -- use external variable
// compile with external.cpp
#include <iostream>
extern double warming;  // use warming from another file

// function prototypes
void update(double dt);
void local();

using std::cout;
void update(double dt)      // modifies global variable
{
    extern double warming;  // optional redeclaration
    warming += dt;          // uses global warming
    cout << "Updating global warming to " << warming;
    cout << " degrees.\n";
}

void local()                // uses local variable
{
    double warming = 0.8;   // new variable hides external one

    cout << "Local warming = " << warming << " degrees.\n";
        // Access global variable with the
        // scope resolution operator
    cout << "But global warming = " << ::warming;
    cout << " degrees.\n";
}
```

#### 作用域解析运算符

在C++中，`::`是作用域解析运算符（scope resolution operator），用于访问全局作用域中的变量或函数，即使在局部作用域中存在同名的变量或函数时也能明确地指定要访问的是全局作用域中的那个.

在你提供的代码中，`::warming`表示访问的是全局作用域中的 `warming`变量，而不是局部作用域中可能存在的同名变量.例如，在 `local()`函数中，虽然有一个局部变量 `warming`，但通过 `::warming`可以访问到全局作用域中的 `warming`变量。

作用域解析运算符的用途：

1. **访问全局变量**：当局部作用域中有与全局变量同名的变量时，使用 `::`可以明确地访问全局变量.
2. **访问类的静态成员**：用于访问类的静态成员变量或静态成员函数.
3. **访问命名空间中的成员**：用于访问命名空间中的变量或函数，尤其是在命名空间中存在同名的局部变量时.

例如，假设有一个全局变量 `int x = 10;`，在某个函数中有一个局部变量 `int x = 20;`，那么在该函数中使用 `x`会访问局部变量，而使用 `::x`则会访问全局变量.

### 静态持续性，内部链接性

将static限定符用于作用域为整个文件的变量时，该变量的链接性为内部的。

链接性为内部的变量执行在其所属的文件中使用；但是常规外部变量都具有外部链接性，即可以在其他文件中使用；

static有一个非常重要的作用是，可以避免在其他文件中有相同的名称时，出现重复定义：

```cpp
// file1
int errors = 20;
...
------------------
// file2
int errors = 20;
...
```

这种情况下，程序将报错，因为违反了单定义规则，file2中的定义也创建了外部变量，因此程序将包含两个errors的两个定义。

但是如果文件定义了一个静态外部变量，其名称与另一个文件中声明的常规外部变量相同，则在该文件中，静态变量将隐藏常规外部变量：

```cpp
// file1
int errors = 20;
...
-----------------
// file2
static int errors = 20;
...
```

这样就不会违反单定义规则，因为static关键字指出标识符errors的链接性为内部。

### 限定符和说明符

存储说明符：

- auto：C++11中不再是说明符；
- register：用于在声明中指示寄存器存储，而在C++11中，它只是显式地指出变量是自动的；
- static：一方面用来声明为内部链接性，另一方面用来声明为无链接性；
- extern：表明为引用声明，即声明引用在其他地方定义的变量；
- thread_local：用于指出变量的持续性与其所属线程的持续性相同；
- mutable：用于指出，即使结构或类变量为const，其某个成员也是可以被修改的；

#### cv-限定符

- const：表明内存被初始化后，程序不能在对它进行修改；
- volatile：表明即使程序代码没有对内存单元进行修改，其值也可能发生改变（某些情况下，硬件可能修改其中的内容)

#### mutable

```cpp
struct data
{
   char name[30];
   mutable int accesses;
}

const data veep = {"Candy", 0};
strcpy(veep.name, "Joye");	// 错误的，不被允许
veep.accesses++;	// 正确的，允许发生 
```

veep的const限定符禁止程序修改veep的成员，但accesses成员的mutable说明符，使其不受这种限制。

#### const

在C++中，const限定符对默认存储类型有影响，即在默认情况下全局变量的链接性为外部的，但是const全局变量的链接性为内部的，即在C++看来，全局const定义就像使用了static说明符一样。

这也解释了为什么，头文件中可以存放const常量。因为内部链接性意味着，每个文件都有自己的一组常量，而不是所有文件共享同一组常量，每个定义都是所属文件私有的，这就是能够将常量定义在头文件中的原因，这样，只要在两个源代码文件中包含同一个头文件，则他们将获得同一组常量；
