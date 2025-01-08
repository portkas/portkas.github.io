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

### 函数和链接性

1. 和变量一样，函数也有链接性，C++中不允许在一个函数中定义另外一个函数，因此所有的函数的存储持续性都自动为静态即在整个程序执行期间都存在；
2. 可以使用static关键字将函数的链接性设置为内部的，使之只能在一个文件中使用，必须同时在函数原型和函数定义在中使用该关键字；

   ```cpp
   static int private(double x);
   static int private(double x){
      ...
   }
   ```
3. 这意味着该函数只能在这个文件中可见，还意味着可以在其他文件中定义同名的函数；
4. 和变量一样，在定义静态函数的文件中，静态函数将覆盖外部定义；
5. 內联函数不受单定义规则的约束，所以可以将內联函数的定义放到头文件中；

# new

### 注意点

1. 动态内存由运算符new/delete控制，而不是由作用域和链接性规则控制；
2. 但是作用域和链接性的规则适用于用来跟踪动态内存的自动和静态指针变量；

   ```cpp
   float *p_free = new float[20];
   ```
3. 由new分配的内存将一直保留在内存中，直到使用delete运算符将其释放；
4. 但是当包含该声明的语句块执行完毕时，p_free指针将消失；
5. 如果希望另一个函数能够使用new分配的内存中的内容，则必须将其地址传递或者返回给其他函数；
6. 如果将p_free的链接性设置为外部的，则文件中位于该声明后面的所有函数都可以使用它，另外通过在另一个文件中使用 `extern float *p_free`的声明就可以使用该指针；

### 使用new初始化

1. 内置的标量类型

   ```cpp
   // 括号
   int *pi = new int(6);		// *pi = 6
   double *pd = new double(9.9);	// *pd = 9.9

   // 初始化列表
   int *pi = new int{6};		// *pi = 6
   double *pd = new double{9.9};	// *pd = 9.9
   ```
2. 常规结构或数组

   ```cpp
   struct where {double x; double y; double z;};
   where *one = new where{2.5, 5.3, 7.2};
   int *ar = new int[4]{1,2,3,4};
   ```

运算符new和new[]分别对应delete和delete[];

### 定位new运算符

包含头文件：`#include <new>`

通常，new负责在堆中找到一个足以满足要求的内存块；new还有另一种变体，被称为定位new运算符，用于指定要使用的位置；通过这种方式，可以在特定位置设置内存管理规程，处理需要通过特定地址进行访问的硬件或在特定位置创建对象；

```cpp
// newplace.cpp -- using placement new
#include <iostream>
#include <new> // for placement new
const int BUF = 512;
const int N = 5;
char buffer[BUF];      // chunk of memory
int main()
{
    using namespace std;

    double *pd1, *pd2;
    int i;
    cout << "Calling new and placement new:\n";
    pd1 = new double[N];           // use heap
    pd2 = new (buffer) double[N];  // use buffer array
    for (i = 0; i < N; i++)
        pd2[i] = pd1[i] = 1000 + 20.0 * i;
    cout << "Memory addresses:\n" << "  heap: " << pd1
        << "  static: " <<  (void *) buffer  <<endl;
    cout << "Memory contents:\n";
    for (i = 0; i < N; i++)
    {
        cout << pd1[i] << " at " << &pd1[i] << "; ";
        cout << pd2[i] << " at " << &pd2[i] << endl;
    }

    cout << "\nCalling new and placement new a second time:\n";
    double *pd3, *pd4;
    pd3= new double[N];            // find new address
    pd4 = new (buffer) double[N];  // overwrite old data
    for (i = 0; i < N; i++)
        pd4[i] = pd3[i] = 1000 + 40.0 * i;
    cout << "Memory contents:\n";
    for (i = 0; i < N; i++)
    {
        cout << pd3[i] << " at " << &pd3[i] << "; ";
        cout << pd4[i] << " at " << &pd4[i] << endl;
    }

    cout << "\nCalling new and placement new a third time:\n";
    delete [] pd1;
    pd1= new double[N];
    pd2 = new (buffer + N * sizeof(double)) double[N]; 
    for (i = 0; i < N; i++)
        pd2[i] = pd1[i] = 1000 + 60.0 * i;
    cout << "Memory contents:\n";
    for (i = 0; i < N; i++)
    {
        cout << pd1[i] << " at " << &pd1[i] << "; ";
        cout << pd2[i] << " at " << &pd2[i] << endl;
    }
    delete [] pd1;
    delete [] pd3;
    // cin.get();
    return 0;
}
```

输出结果：

```bash
$ ./app
Calling new and placement new:
Memory addresses:
  heap: 0x5b00d966b6c0  static: 0x5b00d7fc0160
Memory contents:
1000 at 0x5b00d966b6c0; 1000 at 0x5b00d7fc0160
1020 at 0x5b00d966b6c8; 1020 at 0x5b00d7fc0168
1040 at 0x5b00d966b6d0; 1040 at 0x5b00d7fc0170
1060 at 0x5b00d966b6d8; 1060 at 0x5b00d7fc0178
1080 at 0x5b00d966b6e0; 1080 at 0x5b00d7fc0180

Calling new and placement new a second time:
Memory contents:
1000 at 0x5b00d966b6f0; 1000 at 0x5b00d7fc0160
1040 at 0x5b00d966b6f8; 1040 at 0x5b00d7fc0168
1080 at 0x5b00d966b700; 1080 at 0x5b00d7fc0170
1120 at 0x5b00d966b708; 1120 at 0x5b00d7fc0178
1160 at 0x5b00d966b710; 1160 at 0x5b00d7fc0180

Calling new and placement new a third time:
Memory contents:
1000 at 0x5b00d966b6c0; 1000 at 0x5b00d7fc0188
1060 at 0x5b00d966b6c8; 1060 at 0x5b00d7fc0190
1120 at 0x5b00d966b6d0; 1120 at 0x5b00d7fc0198
1180 at 0x5b00d966b6d8; 1180 at 0x5b00d7fc01a0
1240 at 0x5b00d966b6e0; 1240 at 0x5b00d7fc01a8
```

1. 定位new运算符把p2放在了数组buffer中，pd2和buffer的地址相同，但是他们两个类型不同，pd2是double指针，buffer是char指针，这也是为什么程序中使用(void*)对buffer进行强制转换；
2. 当再次使用定位new运算符指向相同的内存时，它会覆盖上一次的数据，所以定位new运算符不跟踪哪些内存已被使用，也不查找未使用的内存块；
3. 程序中没有使用delete来释放使用定位new运算符分配的内存，因为在这个示例代码中buffer指定的内存是静态内存，而delete只能作用于常规new运算符分配的堆内存；
4. 如果buffer是使用常规的new运算符创建的，那么也可以使用常规delete运算符来释放整个内存块；

# 名称空间

名称可以是变量，函数，结构，枚举，类，类和结构的成员。例如，两个库可能都定义了a,b,c的类，但是定义的方式不兼容，用户可能希望使用一个库的a，另一个库的b，这种冲突被称为名称空间问题；

### using声明和using编译

#### using声明

- **作用**：`using`声明用于将一个或多个特定的名称从命名空间中引入到当前作用域中。
- **语法**：`using namespace_name::identifier;`
- **示例**：
  ```cpp
  using std::cout;
  using std::endl;
  ```
- **效果**：在上述示例中，`cout`和 `endl`被直接引入到当前作用域中，可以在不加 `std::`前缀的情况下直接使用它们。
- **适用场景**：当你只需要从命名空间中使用少量的名称时，使用 `using`声明是更好的选择，因为它可以避免命名冲突。

#### using编译指令

- **作用**：`using`编译指令用于将整个命名空间中的所有名称引入到当前作用域中。
- **语法**：`using namespace namespace_name;`
- **示例**：
  ```cpp
  using namespace std;
  ```
- **效果**：在上述示例中，`std`命名空间中的所有名称都被引入到当前作用域中，可以在不加 `std::`前缀的情况下直接使用它们。
- **适用场景**：当你需要频繁地使用某个命名空间中的多个名称时，使用 `using`编译指令可以减少代码的冗余。然而，过度使用可能会导致命名冲突和代码可读性降低。

#### 注意事项

1. using声明不能同时声明两次，但是使用using编译之后，依然可以使用作用域解析运算符；
