---
title: Mat
categories:
	- OpenCV
---
<!-- more -->

# Mat数据

## 构造函数

```cpp
include <iostream>
#include <opencv2/opencv.hpp>
using namespace std;

int main(){
    cv::Mat a;     //默认构造函数                                         
    cv::Mat b = cv::Mat();  //默认构造函数
    cv::Mat c = cv::Mat(3, 3, CV_8UC1);  //指定类型的二维数组
    cv::Mat d = cv::Mat(cv::Size(3, 3),CV_8UC1); //指定类型的二维数组
    cv::Mat e = cv::Mat(cv::Size(3, 3), CV_32FC2, cv::Scalar(1, 2));   //指定初始化值
    cv::Mat f = cv::Mat(cv::Size(3, 3), CV_8UC3, cv::Scalar(1, 2, 3)); //指定初始化值

    cout << "a = " << a << endl;
    cout << "b = " << b << endl;
    cout << "c = " << c << endl;
    cout << "d = " << d << endl;
    cout << "e = " << e << endl;
    cout << "f = " << f << endl;
    return 0;
}
```

CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.10)
project(OpenCVExample)

find_package(OpenCV REQUIRED)
add_executable(app matbuild.cpp)
target_link_libraries(app ${OpenCV_LIBS})
```

输出：

```bash
$ ./app 
a = []
b = []
c = [  0,   0,   0;
   0,   0,   0;
   0,   0,   0]
d = [  0,   0,   0;
   0,   0,   0;
   0,   0,   0]
e = [1, 2, 1, 2, 1, 2;
 1, 2, 1, 2, 1, 2;
 1, 2, 1, 2, 1, 2]
f = [  1,   2,   3,   1,   2,   3,   1,   2,   3;
   1,   2,   3,   1,   2,   3,   1,   2,   3;
   1,   2,   3,   1,   2,   3,   1,   2,   3]
```

1. 默认构造函数

   ```cpp
   cv::Mat()
   ```

   创建的是一个空的cv::Mat对象，需要在后续使用中为其分配数据；
2. 指定类型的二维数组

   ```cpp
   cv::Mat(int rows, int cols, int type);
   ```

   rows和cols分别是矩阵的行数和列数，type是矩阵的数据类型和通道数，例如 `CV_8UC3`；
3. 指定类型的二维数组，大小由size指定

   ```cpp
   cv::Mat(cv::Size size, int type);
   ```
4. 指定类型的二维数组，并指定初始化值

   ```cpp
   cv::Mat(int rows, int cols, int type, const Scalar& s);
   ```

   创建一个指定大小和类型的矩阵，并用Scalar类型的值s初始化矩阵的所有元素，Scalar可以是一个标量值或一个包含多个值的数据，用于初始化多通道矩阵；
5. 指定类型的二维数组，并指定初始化值，大小由size指定

   ```cpp
   cv::Mat(cv::Size size, int type, const Scalar& s);
   ```
6. 指定类型的多维数组

   ```
   cv::Mat(int ndims, const int* sizes, int type);
   ```
7. 从其他矩阵创建子矩阵

   ```cpp
   cv::Mat(const Mat& m, const Range& rowRange, const Range& colRange);
   ```

   创建一个矩阵的子矩阵，m是原始矩阵，rowRange和colRange分别是子矩阵的行范围和列范围；
8. 指定类型的多维数组，并指定预先存储的数据

   ```cpp
   cv::Mat(int rows, int cols, int type, void* data, size_t step=AUTO_STEP)
   ```

   使用现有的内存数据创建一个矩阵，data是指向数据的指针，step是每行数据的字节大小，如果step为AUTO_STEP则自动计算步长；

## 类matlab函数

```cpp
#include <iostream>
#include <opencv2/opencv.hpp>
using namespace std;

int main(){
    cv::Mat Me = cv::Mat::eye(4, 4, CV_64F);
    cout << "Me = " << Me << endl;
    cv::Mat Mo = cv::Mat::ones(4, 4, CV_64F);
    cout << "Mo = " << Mo << endl;
    cv::Mat Mz = cv::Mat::zeros(4, 4, CV_64F);
    cout << "Mz = " << Mz << endl;
    return 0;
}


输出：
$ ./app 
Me = [1, 0, 0, 0;
 0, 1, 0, 0;
 0, 0, 1, 0;
 0, 0, 0, 1]
Mo = [1, 1, 1, 1;
 1, 1, 1, 1;
 1, 1, 1, 1;
 1, 1, 1, 1]
Mz = [0, 0, 0, 0;
 0, 0, 0, 0;
 0, 0, 0, 0;
 0, 0, 0, 0]
```

## 自定义数据

```cpp
#include <iostream>
#include <opencv2/opencv.hpp>
using namespace std;

int main(){
    cv::Mat m = (cv::Mat_<int>(3,3) << 1,2,3,4,5,6,7,8,9);
    cout<<m<<endl;
    return 0;
}
```

# .clone()方法

.clone()方法用于创建一个cv::Mat对象的完整副本，它会复制矩阵的所有数据，包括大小，类型和内容。使用.clone()可以确保新矩阵与原始矩阵完全独立，对新矩阵的修改，不会影响原始矩阵。

```cpp
cv::Mat mat1 = cv::Mat::ones(3, 3, CV_8UC1); 
cv::Mat mat2 = mat1.clone(); // 创建 mat1 的副本
```
