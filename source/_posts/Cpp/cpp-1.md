---
title: cpp-1
categories:
	- cpp
---
# explicit

explicit关键字是一个类修饰符，用于修饰构造函数或转换操作符，以防止类的构造函数或转换操作符进行隐式类型转换。

<!-- more -->

## 修饰构造函数

```cpp
class MyClass {
public:
    explicit MyClass(int value) : value_(value) {}
private:
    int value_;
};

int main() {
    MyClass myObject = 5; // 错误：隐式转换
    MyClass myObject2(5); // 正确：显式构造
}
```

## 修饰转换操作符

1. 类可以定义自己的转换操作符，并使用explicit关键字防止

```cpp
class MyClass {
public:
    explicit operator int() const { return value_; }
private:
    int value_;
};

int main() {
    MyClass myObject;
    int value = myObject; // 错误：隐式转换
    int value2 = static_cast<int>(myObject); // 正确：显式转换
}
```

MyClass定义了一个转换为int的转换操作符，并将其声明为explicit，因此只能通过显示类型转换来获取int类型的值。

## 注意事项

1. explicit关键字只能用于单个参数的构造函数或转换操作符；
2. 如果构造函数或转换操作符只有一个参数，并且该参数是类类型或引用类型，则explicit关键字是不必要的，因为这种情况下编译器不会进行隐式类型转换。

# static

static关键字主要用于控制变量和函数的生命周期，作用域以及访问权限。

## 静态局部变量

1. 在函数内部使用static关键字修饰的变量称为静态局部变量；
2. 静态局部变量在程序的整个生命周期内存在，不会因为离开作用域而被销毁；
3. 其值会在下一次函数调用时保持；
4. 静态局部变量只在声明它的函数内部可见；
5. 静态局部变量默认初始化为0；

```cpp
#include <iostream>

void func(){
    static int count = 0;
    count++;
    std::cout<<count<<std::endl;
}

int main(){
    int count = 0;
    std::cout<<"**"<<count<<"**"<<std::endl;
    for (int i = 0; i < 5; i++)
    {
        func();
    }
    std::cout<<"**"<<count<<"**"<<std::endl;
    return 0;
}
```

输出结果：

```bash
zhm@Ubuntu:~/Desktop/test/static$ ./app 
**0**
1
2
3
4
5
**0**
```

## 静态全局变量

1. 在文件作用于声明的静态全局变量只在声明它的文件内可见，不能被其他文件访问；

## 类成员

### 静态成员变量

1. 在类中声明的静态成员变量属于类本身，而不是类的任何对象；
2. 所有类的对象共享同一个静态成员变量的副本；
3. 静态成员变量必须在类外部单独定义，以便为其分配存储空间。

```cpp
class MyClass {
public:
    static int staticVar;
};

int MyClass::staticVar = 0; // 在类外部初始化
```

### 静态成员函数

1. 在类中使用static关键字修饰的成员函数是静态成员函数；
2. 静态成员函数不能直接访问非静态成员变量或非静态成员函数；
3. 静态成员函数可以通过类名调用，而不需要创建类的实例。

```cpp
class MyClass {
public:
    static void staticFunc() {
        // 静态成员函数的实现
    }
};

MyClass::staticFunc(); // 直接通过类名调用
```

### 静态常量成员变量

1. 在类中声明的静态常量成员变量可以在类内部初始化，不需要在类外单独初始化。

```cpp
class MyClass {
public:
    static const int constVar = 10; // 在类内部初始化
};
```

## 多线程

1. 在C++11及以后版本，static关键字可以与thread_local一起使用，声明线程局部存储的静态变量；
2. 每个线程都会拥有该变量的一个独立副本。

```cpp
thread_local static int threadVar = 0; // 每个线程都有自己的 threadVar 副本
```

# 类型转换

1. reinterpret
2. const_case
3. static_case
4. dynamic_case

## reinterpret

1. 用于指针或引用之间进行转换，或者将指针转换为足够大的整数类型；
2. 可以将整型转换为指针，也可以把指针转换为数组；
3. 可以在指针和引用里随意转换，不进行检查；
4. 平台移植性比较差。

* 指针类型转换：将一个指针类型转换为另一个指针类型；

  ```cpp
  #include <iostream>

  int main(){
      int* intPtr = new int(10);
      std::cout<<"**"<<sizeof(intPtr)<<":"<<intPtr<<"**"<<std::endl;
      char* charPtr = reinterpret_cast<char*>(intPtr);
      std::cout<<"**"<<sizeof(intPtr)<<":"<<static_cast<void*>(charPtr)<<"**"<<std::endl;
      std::cout<<"**"<<sizeof(intPtr)<<":"<<*charPtr<<"**"<<std::endl;
      std::cout<<"**"<<sizeof(intPtr)<<":"<<charPtr<<"**"<<std::endl;
      return 0;
  }

  输出：
  $ ./app 
  **8:0x62143fa4f2b0**
  **8:0x62143fa4f2b0**
  **8:
  **
  **8:
  **
  ```

  - charPtr是通过reinterpret_cast从intPtr转换来的，指向一个整数10的内存地址；
  - 当尝试输出charPtr时，std::cout会尝试将其作为字符串来输出，由于intPtr指向的内存并不是一个以空字符结尾的字符串，所以std::cout无法正确输出字符串的内容，导致输出为空或者乱码；
  - 如果想要输出charPtr的地址而不是它指向的内容，需要显示地将其转换为 `void*`类型，因为std::cout会以16进制输出 `void*`类型的指针地址；
* 指针到整型的转换：将指针转换为整数类型，通常用于指针的数值表示;

  ```cpp
  #include <iostream>

  int main(){
      int* intPtr = new int(10);
      std::cout<<"**"<<sizeof(intPtr)<<":"<<intPtr<<"**"<<std::endl;

      long ptrValue = reinterpret_cast<long>(intPtr);
      std::cout<<"**"<<sizeof(ptrValue)<<":0x"<<std::hex<<ptrValue<<"**"<<std::endl;
      return 0;
  }

  输出结果：
  $ ./app 
  **8:0x5b06cb0fe2b0**
  **8:0x5b06cb0fe2b0**
  ```
* 整型到指针的转换：将整数转换回指针类型，前提是该整数是之前从指针转换来的；

## const_cast

1. const_cast用于移除或添加const和volatile属性，而不改变指针或引用的类型；
2. 常量指针转换为非常量指针，并且仍然指向原来的对象；
3. 常量引用转换为非常量引用，并且仍然指向原来的对象；
4. 主要用于在需要修改常数数据的情况下进行转换；

* 移除const属性：

  ```cpp
  #include <iostream>

  int main(){
      const int* constIntPtr = new int(10);
      std::cout<<"**"<<sizeof(constIntPtr)<<":"<<*constIntPtr<<"**"<<std::endl;

      int* intPtr = const_cast<int*>(constIntPtr);
      *intPtr = 20;

      std::cout<<"**"<<sizeof(intPtr)<<":"<<*intPtr<<"**"<<std::endl;
      return 0;
  }

  编译运行：
  $ ./app 
  **8:10**
  **8:20**
  ```
* 添加const属性：

  ```cpp
  int* intPtr = new int(10);
  const int* constIntPtr = const_cast<const int*>(intPtr); // 添加 const 属性
  ```

## static_cast

1. 用于基本数据类型之间的转换，如把int转换为char；
2. 把任何类型的表达式转换为void类型；
3. 也用于在有继承关系的类之间进行向上转型和向下转型；

* 向上转型：将派生类指针或引用转换为基类指针或引用，是安全的；
* 向下转型：将基类指针或引用转换为派生类指针或引用，由于static_cast没有运行时类型检查，因此如果转换不正确可能会导致未定义行为，是不安全的；

```cpp
class Base {};
class Derived : public Base {};

Derived* derivedPtr = new Derived();
Base* basePtr = static_cast<Base*>(derivedPtr); // 向上转型
```

```cpp
Base* basePtr = new Derived();
Derived* derivedPtr = static_cast<Derived*>(basePtr); // 向下转型
```

## dynamic_cast

1. dynamic_cast是一种运行时类型转换操作符，主要用于在有继承关系的类之间进行向下转型；
2. 在进行向下转型时 `dynamic_cast`具有类型检查（信息在虚函数中)的功能，比 `static_cast`更安全；
3. 转换后必须是类的指针，引用或者 `void*`，基类要有虚函数可以交叉转换；
4. dynamic_cast本身只能用于存在虚函数的父子关系的强制类型转换；
5. 对于指针转换失败则返回nullptr，对于引用转换失败会抛出std::bad异常；

```cpp
class Base {};
class Derived : public Base {};

Base* basePtr = new Base();
Derived* derivedPtr = dynamic_cast<Derived*>(basePtr); // 转换结果为 nullptr
```

# const

应尽可能使用const：

1. 使用const可以避免无意中修改数据的编译错误；
2. 使用const使函数能够处理const和非const实参，否则将只能接受非const数据；
3. 使用const引用使函数能够正确生成并使用临时变量；

## 基本概念

* 顶层const：表示对象本身是常量；
* 底层const：表示指针或引用所指向的对象是常量；

```cpp
int i = 10;
const int ci = 10;	// 顶层const：ci本身是常量
const int* p1 = &i;	// 底层const：p1所指向的对象是常量
int* const p2 = &i;	// 顶层const：p2本身是常量
const int* const p3 = &i;  // 既有顶层const又有底层const
```

## 区分方法

### 从右往左读

遇到p就读作 `p is a`，遇到 `*`就读作 `point to`

```cpp
const int p;		// p is a int const
const int *p;		// p is a point to int const
int const *p;		// p is a point to const int
int* const p;		// p is a const point to int
const int* const p;	// p is a const point to int const
int const* const p;	// p is a const point to const int
```

### const默认修饰左边

const默认修饰它左边的符号，如果左边没有，那么就修饰它右边的符号。

```cpp
const int *p;		// 左边没有，右边第一个是int，所以p指针指向的值不能改变；
int const *p;		// 左边是int，所以p指针指向的值不能改变；
int* const p;		// 左边是*，所以指针是不能改变的；
const int* const p;	// 第一个修饰int，第二个修饰*，所以指针和指针指向的值都不能改变；
const int const *p;	// 两个修饰的都是int，重复修饰；
```

### 常量指针和指针常量

```cpp
#include<iostream>
using namespace std;

void constValue(){
    int x = 10;
    int y = 20;
    const int *p = &x;
    cout<<"p: "<<p<<" : "<<*p<<endl;
    x = 20;     // 正确
    cout<<"p: "<<p<<" : "<<*p<<endl;
    p = &y;     // 正确
    cout<<"p: "<<p<<" : "<<*p<<endl;
    // *p = 30; // 错误
}

void constPointer(){
    int x = 10;
    int y = 20;
    int *const p = &x;
    cout<<"p: "<<p<<" : "<<*p<<endl;
    x = 20;     // 正确
    cout<<"p: "<<p<<" : "<<*p<<endl;
    *p = 30;    // 正确 
    cout<<"p: "<<p<<" : "<<*p<<endl;
    // p = &y;  // 错误
}

int main(){
    constPointer();
    return 0;
}
```

1. 指针常量(指向常量的指针)：指针指向的是一个常量，不能通过指针来修改它所指向的值；
   1. const int *p = &x;
   2. 可以改变p使其指向不同的变量，因为p不是常量；
   3. 可以改变x的值，因为x不是常量；
2. 常量指针：指针本身是常量，不能指向不同的变量，但可以通过指针来修改它所指向的值；
   1. int *const p = &x;
   2. x=20; 合法；
   3. *p = 20; 合法；
   4. p = &y; 不合法；


# volatile

1. volatile表示易变的，用于告诉编译器这个变量可能会在程序的控制之外被改变，因此编译器在优化时不能对访问该变量的代码进行优化；
2. 会从内存中重新装载内容，而不是直接从寄存器拷贝内容；
3. 指令关键字，确保本条指令不会因编译器的优化而省略，且要求每次直接读值，确保对特殊地址的稳定访问；
4. 使用场合：在中断服务程序和cpu相关寄存器的定义

* 硬件寄存器：当变量与硬件寄存器相关联时，硬件可能会随时改变寄存器的值；
* 中断服务例程：在多线程或中断驱动的程序中，volatile变量可能在中断服务例程中被修改；

```cpp
for(volatitle int i=0; i<1000; i++);	// 它会执行，不会被优化
```

# std::move()

1. std::move()是为了转移所有权，将快要销毁的对象转移给其他变量，这样可以继续使用这个对象，而不必再创建一个一样的对象，省去了创建一个一样新的对象，也提高了性能;
2. 引入std::move()主要是为了优化对象的声明周期，以及优化函数参数传递方式；
3. 在实际场景中，`右值引用`和 `std::move`被广泛用于在STL和自定义类中实现移动语义，避免拷贝从而提升程序性能；
4. std::move()与std::forward()都仅仅做了类型转换(可理解为static_cast转换) 而已。真正的移动操作是在移动构造函数或者移动赋值操作符中发生的；

## 函数原型

```cpp
/**
 *  @brief  Convert a value to an rvalue.
 *  @param  __t  A thing of arbitrary type.
 *  @return The parameter cast to an rvalue-reference to allow moving it.
*/
template <typename _Tp>
constexpr typename std::remove_reference<_Tp>::type &&move(_Tp &&__t) noexcept
{
    return static_cast<typename std::remove_reference<_Tp>::type &&>(__t);
}

// remove_reference
template <typename _Tp>
struct remove_reference
{
    typedef _Tp type;
};

template <typename _Tp>
struct remove_reference<_Tp &>
{
    typedef _Tp type;
};

template <typename _Tp>
struct remove_reference<_Tp &&>
{
    typedef _Tp type;
};
```

1. `remove_reference`的作用是去除 `T`中的引用部分，只获取其中的类型部分。无论 `T`是左值还是右值，最后只获取它的类型部分。
2. constexpr表示这个函数可以在编译时计算结果；
3. `typename std::remove_reference<_Tp>::type&&`表示先去除参数类型中的引用部分，然后再加上 `&&`表示右值引用；
4. `move(_Tp&& __t) noexcept`函数接受一个右值引用参数__t，并声明为noexcept表示该函数不会抛出异常；
5. `static_cast<typename std::remove_reference<_Tp>::type&&>(__t)`: 这行代码将参数 `__t`转换为右值引用。`static_cast`用于显式类型转换，将 `__t`转换为去除引用后的类型，并加上 `&&`来表示右值引用。
6. 函数模板 `move`的作用是将一个左值或右值转换为右值引用。通过使用 `std::remove_reference`和 `&&`，它确保了返回类型是一个右值引用，从而允许对象被移动而不是被复制。

## typename

1. typename关键字用于告诉编译器某个依赖名称（依赖于模板参数的名称）是一个类型；
2. 模板函数并不创建任何函数，而只是告诉编译器如何定义函数，当传入某个类型时，编译器按照模板模式再创建这样的函数；

```cpp
constexpr typename std::remove_reference<_Tp>::type&&
```

* `std::remove_reference<_Tp>::type` : 这是一个依赖名称，因为它依赖于模板参数 `_Tp`。
* `typename`用于告诉编译器 `std::remove_reference<_Tp>::type`是一个类型。

### 为什么需要typename：

在模板编程中，编译器在解析模板代码时，需要知道某个名称是类型还是非类型。对于非依赖名称（不依赖于模板参数的名称），编译器可以很容易地确定其类型。但对于依赖名称（依赖于模板参数的名称），编译器需要显式地使用 `typename`来指示这是一个类型。

* 非依赖名称：例如int*，编译器知道int*是一个类型；
* 依赖名称：std::remove_reference<_Tp>::type，编译器需要typename来明确这是一个类型；

```cpp
class MyClass {
    using ValueType = vector<int>::value_type;
};
```

这里的 `vector<int>`为非依赖名称，ValueType会直接被解析为int，程序没有错误；

```cpp
template <typename T>
class MyClass {
    using ValueType = typename T::value_type;
};
```

这里的 `T`为依赖名称，所以需要typename来告诉编译器 `T::value_type`是一个类型；如果不加typename编译器会报错：

```bash
$ g++ -o app main.cpp 
main.cpp:6:23: error: need ‘typename’ before ‘T::value_type’ because ‘T’ is a dependent scope
    6 |     using valueType = T::value_type;
      |                       ^
      |                       typename
```


## 示例1

```cpp
#include<iostream>
#include<string>
#include<vector>

void TestSTLObject()
{
    std::string str = "Hello";
    std::vector<std::string> v;
 
    // uses the push_back(const T&) overload, which means
    // we'll incur the cost of copying str
    v.push_back(str);
    std::cout << "After copy, str is \"" << str << "\"\n";
 
    // uses the rvalue reference push_back(T&&) overload,
    // which means no strings will be copied; instead, the contents
    // of str will be moved into the vector.  This is less
    // expensive, but also means str might now be empty.
    v.push_back(std::move(str));
    std::cout << "After move, str is \"" << str << "\"\n";
 
    std::cout << "The contents of the vector are \"" << v[0]
                                         << "\", \"" << v[1] << "\"\n";
 
}

int main(){
    TestSTLObject();
    return 0;
}
```

编译运行：

```bash
$ ./app 
After copy, str is "Hello"
After move, str is ""
The contents of the vector are "Hello", "Hello"
```

## 示例2

```cpp
// stdmove.cpp -- using std::move()
#include <iostream>
#include <utility>
// use the following for g++4.5
// #define nullptr 0
// interface
class Useless
{
private:
    int n;          // number of elements
    char * pc;      // pointer to data
    static int ct;  // number of objects
    void ShowObject() const;
public:
    Useless();
    explicit Useless(int k);
    Useless(int k, char ch);
    Useless(const Useless & f); // regular copy constructor
    Useless(Useless && f);      // move constructor
    ~Useless();
    Useless operator+(const Useless & f)const;
    Useless & operator=(const Useless & f); // copy assignment
    Useless & operator=(Useless && f);      // move assignment 
    void ShowData() const;
};

// implementation
int Useless::ct = 0;

Useless::Useless()
{
    ++ct;
    n = 0;
    pc = nullptr;
 }

Useless::Useless(int k) : n(k)
{
    ++ct; 
    pc = new char[n];
}

Useless::Useless(int k, char ch) : n(k)
{
    ++ct;
    pc = new char[n];
    for (int i = 0; i < n; i++)
        pc[i] = ch;
}

Useless::Useless(const Useless & f): n(f.n) 
{
    ++ct;
    pc = new char[n];
    for (int i = 0; i < n; i++)
        pc[i] = f.pc[i];
}

Useless::Useless(Useless && f): n(f.n) 
{
    ++ct;
    pc = f.pc;       // steal address
    f.pc = nullptr;  // give old object nothing in return
    f.n = 0;
}

Useless::~Useless()
{
    delete [] pc;
}

Useless & Useless::operator=(const Useless & f)  // copy assignment
{
    std::cout << "copy assignment operator called:\n";
    if (this == &f)
        return *this;
    delete [] pc;
    n = f.n;
    pc = new char[n];
    for (int i = 0; i < n; i++)
        pc[i] = f.pc[i];
    return *this;
}

Useless & Useless::operator=(Useless && f)       // move assignment
{
    std::cout << "move assignment operator called:\n";
    if (this == &f)
        return *this;
    delete [] pc;
    n = f.n;
    pc = f.pc;
    f.n = 0;
    f.pc = nullptr;
    return *this;
}

Useless Useless::operator+(const Useless & f)const
{
    Useless temp = Useless(n + f.n);
    for (int i = 0; i < n; i++)
        temp.pc[i] = pc[i];
    for (int i = n; i < temp.n; i++)
        temp.pc[i] = f.pc[i - n];
    return temp;
}

void Useless::ShowObject() const
{ 
    std::cout << "Number of elements: " << n;
    std::cout << " Data address: " << (void *) pc << std::endl;
}

void Useless::ShowData() const
{
    if (n == 0)
        std::cout << "(object empty)";
    else
        for (int i = 0; i < n; i++)
            std::cout << pc[i];
    std::cout << std::endl;
}

// application
int main()
{
    using std::cout;
    {
        Useless one(10, 'x');
        Useless two = one +one;   // calls move constructor
        cout << "object one: ";
        one.ShowData();
        cout << "object two: ";
        two.ShowData();
        Useless three, four;
        cout << "three = one\n";
        three = one;              // automatic copy assignment
        cout << "now object three = ";
        three.ShowData();
        cout << "and object one = ";
        one.ShowData();
        cout << "four = one + two\n";
        four = one + two;         // automatic move assignment
        cout << "now object four = ";
        four.ShowData();
        cout << "four = move(one)\n";
        four = std::move(one);    // forced move assignment
        cout << "now object four = ";
        four.ShowData();
        cout << "and object one = ";
        one.ShowData();
    }
}
```

编译运行：

```bash
$ ./app
object one: xxxxxxxxxx
object two: xxxxxxxxxxxxxxxxxxxx
three = one
copy assignment operator called:
now object three = xxxxxxxxxx
and object one = xxxxxxxxxx
four = one + two
move assignment operator called:
now object four = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
four = move(one)
move assignment operator called:
now object four = xxxxxxxxxx
and object one = (object empty)
```

# 左值引用

## 使用方法

通常所说的引用均为左值引用：

1. 引用是已定义的变量的别名；
2. 引用变量的主要用途是用作函数的形参，通过将引用变量作为参数，函数将使用原始变量，而不是其副本；
3. 必须在声明引用时将其初始化，而不能像指针那样先声明再赋值；
4. 这里的"一旦与某个变量关联起来，就不能改变"指的是地址；lvalue关联了变量n，那么lvalue就不能再关联其他变量了，即lvalue的地址就不能再改变；但是lvalue的值是可以改变的；
5. 引用变量和原始变量指向相同的值和内存单元；

   ```cpp
   #include<iostream>
   #include<string>
   #include<vector>

   void leftValue()
   {
       int n = 10;
       int &lvalue = n;
       std::cout << lvalue <<std::endl;
       std::cout << &n <<std::endl;
       std::cout << &lvalue <<std::endl;

       int num = 50;
       lvalue = num;
       std::cout << n <<std::endl;
       std::cout << lvalue <<std::endl;
       std::cout << num <<std::endl;
       std::cout << &n <<std::endl;
       std::cout << &lvalue <<std::endl;
       std::cout << &num <<std::endl;
   }

   int main(){
       leftValue();
       return 0;
   }
   ```

运行结果：

```cpp
$ ./app
10
0x7ffc91710998
0x7ffc91710998
50
50
50
0x7ffc91710998
0x7ffc91710998
0x7ffc9171099c
```

## 注意事项

返回引用时最重要的一点是，应避免返回<函数终止时不再存在的内存单元>例如：

```cpp
const int& clone(int &p){
    int newguy;
    newguy = p;
    return newguy;
}

int main(){
    int n = 10;
    int guy = clone(n);
    std::cout<< guy <<std::endl;
    return 0;
}
```

该函数返回一个指向临时变量(newguy)的引用，函数运行完毕后它将不再存在。

解决办法：

1. 为了避免这种问题，最简单的方法是返回一个作为参数传递给函数的引用，作为参数的引用指向调用函数使用的数据，因此返回的引用也将指向这些数据；
2. 另一种方法是使用new来分配新的存储空间；

# 右值引用

1. 右值引用的声明符号为 `&&`，用以引用一个右值，可以延长右值的生命周期；
2. 左值是一个可以表示数据的表达式（变量名，解除引用的指针)，程序可以获取它的地址，右值则不能对其取地址；
3. 但是，如果将右值关联到右值引用，将导致该右值被存储到特定的位置，且可以获取该位置的地址；
4. ```cpp
   #include <iostream>

   inline double f(double tf){return 5.0*(tf-32.0)/9.0;}
   int main(){
       double tc = 21.5;
       double &&rd1 = 7.07;
       double &&rd2 = f(rd1);
       std::cout<< "tc value and address: "<<tc<<", "<<&tc<<std::endl;
       std::cout<< "rd1 value and address: "<<rd1<<", "<<&rd1<<std::endl;
       std::cout<< "rd2 value and address: "<<rd2<<", "<<&rd2<<std::endl;
       return 0;
   }

   编译运行：
   $ ./app
   tc value and address: 21.5, 0x7fff68ec89d0
   rd1 value and address: 7.07, 0x7fff68ec89d8
   rd2 value and address: -13.85, 0x7fff68ec89e0
   ```
5. 引入右值引用的主要目的之一是实现移动语义；

## 移动语义

```cpp
vector<string> vstr;
// 省略代码：vstr存储2000个string，每个string长度为1000
vector<string> vstr_copy(vstr);
```

vector和string类都使用动态内存分配，因此需要某种new版本的复制构造函数，为了初始化vstr_copy，复制构造函数 `vector <string>`将使用new给2000个string对象分配内存，每个string对象又需要调用string的复制构造函数，这个构造函数将又将使用new给1000个字符分配内存，最后全部2000000个字符才从vstr控制的内存中复制到vstr_copy控制的内存中。

```cpp
#include <iostream>
#include <vector>
using namespace std;

vector<string> allcaps(const vector<string> &vs){
    vector<string> temp;
    // 省略代码：将vs中的所有小写转大写存储到temp中
    return temp;
}

int main(){
    vector<string> vstr;
    // 省略代码：vstr存储2000个string，每个string长度为1000
    vector<string> vstr_copy(allcaps(vstr));
    return 0;
}
```

allcops()函数创建对象temp，该对象管理着2000000个字符，vector和string的复制构造函数创建这2000000个字符的副本，然后程序删除allcops()返回的临时对象（编译器会将temp复制给一个临时返回对象，然后删除temp再删除临时返回对象)，这里做了大量的无用功。

如果使用移动语义，编译器直接将数据的所有权转让给vstr_copy，而不需要先将字符复制新地方再删除原来的字符。

要实现移动语义，需要采取某种方式让编译器知道什么时候需要复制，什么时候不需要复制。这就是右值引用发挥作用的地方。

# 内联函数

1. 内联函数的目的是为了提高程序的运行速度；
2. 与常规函数的主要区别在于C++编译器如何将它们组合到程序中；
3. 

# 特殊的成员函数

* 默认构造函数
* 复制构造函数
* 复制赋值运算符
* 析构函数
* 移动构造函数
* 移动赋值运算符

如果没有给类定义任何构造函数，编译器将提供一个默认构造函数；

对于使用内置类型的成员，默认的默认构造函数不对其进行初始化；对于属于类对象的成员，则调用其默认构造函数；

如果自己写了析构函数，复制构造函数或复制赋值运算符，编译器就不会自动提供移动构造函数和移动赋值运算符；

如果自己写了移动构造函数或移动赋值操作符，编译器将不会自动提供复制构造函数和复制赋值运算符；

## 默认和禁用

如果自己编写了移动构造函数，因此编译器将不会自动创建默认的构造函数，复制构造函数以及复制赋值操作符。这时候可以使用 `default`显式地声明这些方法的默认版本：

```cpp
class someclass
{
public:
    someclass(someclass &&){};
    someclass() = default;
    someclass(const someclass &) = default;
    someclass& operator=(const someclass &) = default;
};
```

此外，关键字 `delete`可用于禁止编译器使用特定方法，如果要禁止复制对象，可禁用复制构造函数和复制赋值运算符：

```cpp
class someclass
{
public:
    someclass() = default;
    someclass(someclass &&) = default;
    someclass& operator=(someclass &&) = default;
    someclass(const someclass &) = delete;
    someclass& operator=(const someclass &) = delete;
};
```
