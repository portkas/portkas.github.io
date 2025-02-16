---
title: cpp-6-智能指针
categories:
	- cpp
---
1. 智能指针模板类

# 智能指针

1. auto_ptr
2. unique_ptr
3. shared_ptr

以上三个智能指针模板都定义了类似指针的对象，可以将new获得的地址赋给这些对象。当智能指针过期的时候，其析构函数将使用delete来释放内存。

使用时可以将每一个智能指针都放在一个代码块内，这样当离开代码的时候，指针将过期，申请的内存也会被自动释放。

所有的智能指针都有一个explicit构造函数，该构造函数将指针作为参数，因此不需要自动将指针转换为智能指针对象。

```cpp
shared_ptr<double> pd;
double *p_reg = new double;
pd = p_reg;	// 错误
pd = shared_ptr<double>(p_reg);	// 正确
shared_ptr<double> pshared = p_reg;	// 错误
shared_ptr<double> pshared(p_reg);	// 正确
```

智能指针对象的很多方面都类似于常规指针：

- 可以对其执行解除引用操作(*p)
- 可以用它来访问结构成员(p->name)
- 将它赋值给指向相同类型的常规指针
- 可以将智能指针对象赋值给另一个同类型的智能指针对象

## 注意事项

```cpp
auto_ptr<string> ps(new string("I reigned by lonely as a cloud."));
auto_ptr<string> vocation;
vocation = ps;
```

如果ps和vocation是常规指针，则两个指针将指向同一个string对象。如果是使用智能指针将会出现严重的问题，即一块内存被释放了两次，一次是ps过期的时候，另一次是vocation过期的时候。

解决办法：

- 定义赋值运算符，使之执行深复制。这样两个指针将指向不同的对象，其中一个对象是另一个对象的副本；
- 建立所有权。对于特定的对象，只能有一个智能指针可以拥有它，这样拥有对象的智能指针的构造函数会删除该对象。然后让赋值操作转让所有权。unique_ptr策略；
- 创建智能更高的指针，跟踪引用特定对象的智能指针数。称为引用计数，仅当最后一个指针过期时，才调用delete，shared_ptr策略；

## unique_ptr与auto_ptr比较

```cpp
auto_ptr<string> p1(new string("auto"));// #1
auto_ptr<string> p2;			// #2
p2 = p1;				// #3
```

在语句#3中，p2接管string对象的所有权后，p1的所有权将被剥夺，按理说这应该是一件好事，可以防止p1和p2的析构函数试图删除同一个对象；但是如果程序随后试图使用p1，这将是一个坏事，因为p1不再指向有效的数据；

```cpp
unique_ptr<string> p3(new string("auto"));// #4
unique_ptr<string> p4;			// #5
p4 = p3;				// #6
```

在使用unique_ptr的时候，这将是不允许的，编译器认为#6语法错误，避免了p3不再指向有效数据的问题。

因此，unique_ptr比auto_ptr更安全。
