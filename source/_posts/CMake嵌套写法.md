---
title: CMake嵌套写法
categories: CMake
---
[ ] CMake嵌套写法

动态库：源文件非常多，生成的可执行文件比较小，发布的时候不仅需要发布可执行文件，还需要发布动态库。
静态库：源文件比较少，生成的可执行文件比较大，发布的时候只需要发布可执行文件就可以了。
<!-- more -->

`CMAKE_CURRENT_SOURCE_DIR`:指向当前正在解析的CMakeLists.txt文件所在目录，它的值会随着CMake处理不同的CMakeLists.txt而变化。
`PROJECT_SOURCE_DIR`:指向项目的根目录，即包含顶层CMakeLists.txt文件所在的目录。这个变量只在项目的顶层CMakeLists.txt文件中有效，即在调用project()命令之后。
`CMAKE_SOURCE_DIR`：总是指向整个项目的根目录，这个变量在项目的顶层CMakeLists.txt文件中等同于`PROJECT_SOURCE_DIR`，并且在子目录中也是可以使用的。
`PROJECT_BINARY_DIR`:指向项目的二进制文件，即CMake生成的构建文件（如Makefile）所在的目录。

父节点里的变量可以在子节点中用（继承）
子节点中定义的变量不能再父节点中用

# 示例
## 文件结构
```
$ tree 
.
├── CMakeLists.txt
├── calc
│   ├── CMakeLists.txt
│   ├── add.cpp
│   ├── div.cpp
│   ├── mult.cpp
│   └── sub.cpp
├── include
│   ├── calc.h
│   └── sort.h
├── sort
│   ├── CMakeLists.txt
│   ├── bubbleSort.cpp
│   ├── insertionSort.cpp
│   └── selectionSort.cpp
├── test01
│   ├── CMakeLists.txt
│   └── sort.cpp
└── test02
    ├── CMakeLists.txt
    └── calc.cpp

5 directories, 16 files
```

## 根目录CMakeLists.txt文件
```CMake
cmake_minimum_required(VERSION 3.10)
project(Demo_r)
# 定义变量
# 静态库生成路径
set(LIBPATH ${PROJECT_SOURCE_DIR}/lib)
# 可执行程序存储目录
set(EXECPATH ${PROJECT_SOURCE_DIR}/bin)
# 头文件路径
set(HEADPATH ${PROJECT_SOURCE_DIR}/include)
# 库文件的名字
set(CALCLIB calc)
set(SORTLIB sort)
# 可执行程序的名字
set(APPNAME1 app1)
set(APPNAME2 app2)

# 给当前节点添加子目录
add_subdirectory(calc)
add_subdirectory(sort)
add_subdirectory(test01)
add_subdirectory(test02)
```

## calc目录中CMakeLists.txt文件
```CMake
cmake_minimum_required(VERSION 3.10)
project(calc)

# 搜索源文件
aux_source_directory(./ SRC)
# 指定包含的头文件
include_directories(${HEADPATH})
# 指定静态库生成的路径
set(LIBRARY_OUTPUT_PATH ${LIBPATH})
# 生成静态库
add_library(${CALCLIB} STATIC ${SRC})
```

## sort目录中CMakeLists.txt文件
```CMake
cmake_minimum_required(VERSION 3.10)
project(sort)

# 搜索源文件
aux_source_directory(./ SRC)
# 指定包含的头文件
include_directories(${HEADPATH})
# 指定静态库生成的路径
set(LIBRARY_OUTPUT_PATH ${LIBPATH})
# 生成静态库
add_library(${SORTLIB} STATIC ${SRC})
```

## test01目录中CMakeLists.txt文件
```CMake
cmake_minimum_required(VERSION 3.10)
project(test01)

aux_source_directory(./ SRC)
include_directories(${HEADPATH})
link_directories(${LIBPATH})
link_libraries(${SORTLIB})
set(EXECUTABLE_OUTPUT_PATH ${EXECPATH})
add_executable(${APPNAME1} ${SRC})
```

## test02目录中CMakeLists.txt文件
```CMake
cmake_minimum_required(VERSION 3.10)
project(test02)

aux_source_directory(./ SRC)
include_directories(${HEADPATH})
link_directories(${LIBPATH})
link_libraries(${CALCLIB})
set(EXECUTABLE_OUTPUT_PATH ${EXECPATH})
add_executable(${APPNAME2} ${SRC})
```