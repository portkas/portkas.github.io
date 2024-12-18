


# explicit

explicit关键字是一个类修饰符，用于修饰构造函数或转换操作符，以防止类的构造函数或转换操作符进行隐式类型转换。

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
