---
title: std::ios_base格式化标志和精度设置
categories:
	- cpp
---
1. cout.setf
2. cout.precision

<!-- more -->

std::ios_base提供了一系列格式化标志，可以用于控制输出的格式，这些格式可以用setf和unsetf方法设置和清除；

#### 常见的格式化标志

* **`std::ios_base::dec`** ：十进制格式（默认）。
* **`std::ios_base::hex`** ：十六进制格式。
* **`std::ios_base::oct`** ：八进制格式。
* **`std::ios_base::fixed`** ：固定小数点格式。
* **`std::ios_base::scientific`** ：科学计数法格式。
* **`std::ios_base::left`** ：左对齐。
* **`std::ios_base::right`** ：右对齐（默认）。
* **`std::ios_base::internal`** ：内部对齐，用于数值的符号或基数前缀。
* **`std::ios_base::boolalpha`** ：布尔值以 `true` 和 `false` 输出。
* **`std::ios_base::noboolalpha`** ：布尔值以 `1` 和 `0` 输出。

```cpp
#include <iostream>

int main() {
    int value = 15;

    // 设置为十六进制格式
    std::cout << std::hex << value << std::endl;  // 输出: f

    // 恢复为十进制格式
    std::cout << std::dec << value << std::endl;  // 输出: 15

    // 设置为固定小数点格式
    double pi = 3.14159265358979323846;
    std::cout << std::fixed << pi << std::endl;  // 输出: 3.141593

    // 设置为科学计数法格式
    std::cout << std::scientific << pi << std::endl;  // 输出: 3.141593e+00

    // 左对齐
    std::cout << std::left << std::setw(10) << value << std::endl;  // 输出: 15        |

    // 右对齐
    std::cout << std::right << std::setw(10) << value << std::endl;  // 输出:        15|

    // 布尔值输出
    bool flag = true;
    std::cout << std::boolalpha << flag << std::endl;  // 输出: true
    std::cout << std::noboolalpha << flag << std::endl;  // 输出: 1

    return 0;
}
```


#### 精度设置

精度设置用于控制浮点数输出的小数位数，可以使用std::setprecision操作符来设置精度；

```cpp
#include <iostream>
#include <iomanip>  // 包含 setprecision

int main() {
    double pi = 3.14159265358979323846;

    // 设置精度为 3 位小数
    std::cout << std::fixed << std::setprecision(3) << pi << std::endl;  // 输出: 3.142

    // 设置精度为 5 位小数
    std::cout << std::fixed << std::setprecision(5) << pi << std::endl;  // 输出: 3.14159

    return 0;
}
```

#### 宽度设置

宽度设置用于控制输出字段的宽度，可以使用std::setw操作符来设置宽度；

```cpp
#include <iostream>
#include <iomanip>  // 包含 setw

int main() {
    int value = 15;

    // 设置字段宽度为 10
    std::cout << std::setw(10) << value << std::endl;  // 输出:        15

    // 左对齐，字段宽度为 10
    std::cout << std::left << std::setw(10) << value << std::endl;  // 输出: 15        |

    return 0;
}

```

#### 填充字符设置

填充字符设置用于控制输出字段的填充字符，可以使用std::setfill操作符来设置填充字符；

```cpp
#include <iostream>
#include <iomanip>  // 包含 setfill

int main() {
    int value = 15;

    // 设置字段宽度为 10，填充字符为 '*'
    std::cout << std::setw(10) << std::setfill('*') << value << std::endl;  // 输出: *****15

    // 左对齐，字段宽度为 10，填充字符为 '*'
    std::cout << std::left << std::setw(10) << std::setfill('*') << value << std::endl;  // 输出: 15********

    return 0;
}
```

#### 保存和恢复格式状态

某些情况下，需要保存当前的格式状态，进行一些特定的格式化输出，然后再恢复原来的格式状态，可以使用std::ios_base::fmtflags和std::streamsize来保存和恢复格式状态；

```cpp
#include <iostream>
#include <iomanip>

using std::ios_base;
using std::cout;
using std::endl;
using std::setprecision;
using std::fixed;

// 保存当前格式状态
ios_base::fmtflags saveFormat(cout.flags());
std::streamsize savePrec(cout.precision());

// 设置新的格式
cout << fixed << setprecision(2);

// 进行一些输出
double pi = 3.14159265358979323846;
cout << "Pi: " << pi << endl;

// 恢复原来的格式
cout.flags(saveFormat);
cout.precision(savePrec);

// 再次进行一些输出
cout << "Pi: " << pi << endl;

return 0;
```
