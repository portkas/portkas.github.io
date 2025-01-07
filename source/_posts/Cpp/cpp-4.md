---
title: cpp-4-回调函数
categories:
	- cpp
---
1. 什么是回调函数
2. 回调函数用法

<!-- more -->

# 回调函数

回调函数，是计算机编程中对某一段可执行代码的引用，它被作为参数传递给另一段代码；

回调函数不是由该函数的实现方直接调用，而是在特定的事件或条件发生时由另外的一方调用的，用于对该事件或条件进行响应；

1. 普通函数的回调
2. 类成员函数的回调
3. 基于std::function和std::bind的回调
4. Lambda表达式的回调

# 普通函数的回调

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <string>
typedef  int (*callBackFunc)(char* name);
int playBegin(char* name)
{
    printf("视频开始解码，即将出现画面....\n");
    return 1;
}
int playEnd(char* name)
{
    printf("视频播放结束....\n");
    return 1;
}
int play(callBackFunc fn, char* name)
{
    return (*fn)(name);
}
int main()
{
   char pName[1024] = "色即是空";
   //视频播放开始....
   play(playBegin,pName);//playBegin函数指针作为参数传递
   //视频播放中....
   //视频播放结束....
   play(playEnd,pName);//playEnd函数指针作为参数传递
   return 0;
}
```

1. playBegin(),playEnd()是普通函数，定义了回调函数的逻辑；
2. play()函数是一个高阶函数，接收函数指针作为参数，并在内部调用回调函数；
3. 在main()中，将函数playBegin(),playEnd()的地址传递给play()实现回调；

需要注意的是：

在 `play` 函数中，`fn` 是一个 `callBackFunc` 类型的参数，即它是一个指向函数的指针。因此，`(*fn)(name)` 和 `fn(name)` 都是合法的函数调用方式，它们都表示通过函数指针 `fn` 调用指向的函数，并传递 `name` 作为参数。

- `(*fn)(name)` 是显式地通过解引用函数指针来调用函数。`*fn` 获取函数指针指向的函数，然后调用该函数。
- `fn(name)` 是更简洁的写法，直接通过函数指针调用函数。在 C 语言中，当函数指针用于调用函数时，可以省略解引用操作符 `*`，因为上下文已经明确了这是一个函数调用操作.

# 类成员函数的回调

### 示例1

由于普通成员函数必须依赖具体对象才能调用，因此在回调时需要传递对象指针和成员函数指针。

```cpp
#include <iostream>
using namespace std;

class CallbackHandler{
public:
    // 成员函数作为回调函数
    void memberCallback(int value){
        cout << "成员函数回调，被调用时传入的值是:" << value << endl;
    }
};

// 一个执行回调的函数
void executableMemberCallback(CallbackHandler* obj, void (CallbackHandler::*callback)(int), int value){
    // 通过对象指针和成员函数指针调用成员函数
    (obj->*callback)(value);
}

int main(){
    // 传递对象和成员函数指针进行回调
    CallbackHandler handler;
    executableMemberCallback(&handler, &CallbackHandler::memberCallback, 42);
    return 0;
}
```

1. CallbackHandler类中定义了一个成员函数memberCallback;
2. executeMemberCallback接收对象指针CallbackHandler* obj和成员函数指针void (CallbackHandler::*callback)(int)
3. 通过(obj->*callback)(value)调用成员函数；
4. 在main函数中，通过对象handler和成员函数指针&CallbackHandler::memberCallback实现回调；

### 示例2

在c++面向对象里面，回调函数是成员函数的情况更常见，这样的好处是，一个类A的一个函数生成一个结果之后，可以调用另一个类B的成员函数。而不必类A拥有B的实例。

尤其是在B中有了A的实例的情况下，A中如果再包含B的实例会出现循环引用的问题 ，这也是可以解决的，但是这种耦合还是容易让逻辑变得混乱。

```cpp
typedef std::function<void (string)> CaptureCallback;  

class CaptureController{
public:
    CaptureCallback callback;
    CaptureController(CaptureCallback callback):callback(callback){};
    void capturePic(CaptureCallback callback){
        string t = "a pic";
        callback(t);
    }
}


class UI{
    //开始捕捉图像
    void startCapture(){
        CaptureController c(std::bind(&UI::renderPic,this,_1)); 
        c.capturePic();
    }
  
    //渲染图片作为回调函数
    void renderPic(string t){
        print(t);
    }
}

//main.cpp
UI ui;
ui.startCapture();
```


# std::function/std::bind

1. std::function可以存储任意可调用对象（普通函数，成员函数，Lambda表达式)
2. std::bind可以绑定成员函数和对象

```cpp
#include <iostream>
#include <functional>
using namespace std;

typedef function<void(int)> CallBackFunc;

void executeCallback(CallBackFunc callback, int value){
    callback(value);
}

void freeFunction(int value){
    cout << "普通函数回调，传入的参数为：" << value << endl;
}

class CallbackHandler{
public:
    void memberCallback(int value){
        cout << "成员函数回调，传入的参数为：" << value << endl;
    }
};

int main(){
    CallbackHandler handler;
    // 1. 传递普通函数作为回调
    executeCallback(freeFunction, 42);

    // 2. 传递Lambda表达式作为回调
    executeCallback([](int value){
        cout << "Lambda 回调，传入的参数为：" << value << endl;
    }, 43);

    // 3. 传递成员函数作为回调
    executeCallback(std::bind(&CallbackHandler::memberCallback, &handler, std::placeholders::_1), 44);

    return 0;
}
```

1. `function<void(int)>`可以存储普通函数，Lambda表达式或绑定后的成员函数；
2. 使用std::bind将成员函数和对象绑定，并通过std::placeholder::_1占位符传递参数；
