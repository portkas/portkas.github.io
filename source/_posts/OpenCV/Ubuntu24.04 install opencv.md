---
title: Ubuntu24.04 install opencv
categories:
    - project
---
1. [opencv](https://opencv.org/releases/)官网下载opencv-4.10.0的source文件并解压
2. 下载[opencv_contrib]()并解压，将opencv_contrib移动到opencv的文件夹中
3. 安装依赖项

<!-- more -->

```bash
sudo apt-get install build-essential
sudo apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
```

4.编译并安装

```bash
$ cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_SHARED_LIBS=OFF -D WITH_OPENMP=ON -D ENABLE_PRECOMPILED_HEADERS=OFF ..

$ make -j8
$ sudo make install
```

5.测试代码
编写测试代码

```C++
#include <opencv2/opencv.hpp>
 
int main(int argc,char **argv){
    cv::Mat src(300,500,CV_8UC3,cv::Scalar::all(255));
    cv::imshow("hello-opencv",src);
    cv::waitKey(0);
}
```

编写CMakeLists.txt文件

```CMake
cmake_minimum_required(VERSION 3.0)
project(Sample)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR})
 
find_package(OpenCV REQUIRED)
set(OpenCV_LIB_DIR ${OpenCV_INSTALL_PATH}/lib)
message(STATUS "OpenCV版本: ${OpenCV_VERSION}")
message(STATUS "    头文件目录：${OpenCV_INCLUDE_DIRS}")
message(STATUS "    库文件目录：${OpenCV_LIB_DIR}")
message(STATUS "    库文件列表：${OpenCV_LIBS}")
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIB_DIR})
add_executable(main main.cpp)
target_link_libraries(main ${OpenCV_LIBS})
```
