---
title: CMake
categories:
    - cmake
---
# 1.CMake概述
CMake是一个项目构建工具，是跨平台的。CMake可以自动生成Makefile文件，管理项目更加简单。
<!-- more -->
## 1.1 CMake使用流程
1.项目中添加CMakeLists.txt文件
2.新建一个名为build的文件夹
3.在build文件夹中执行cmake <CMakeLists-file-path>构建makefile文件
4.执行make指令

# 2.CMake的用法
## 2.1 查看版本号
```bash
$ cmake --version       # 查看版本号
cmake version 3.28.3
```

## 2.2 注释
```CMake
# 使用 # 进行行注释
# 这是一行注释

# 使用 #[[]] 进行块注释
#[[
    这是块注释
]]
```

## 2.3 常用的一些宏
* `CMAKE_CURRENT_SOURCE_DIR`：表示当前访问的 CMakeLists.txt 文件所在的路径。
* `CMAKE_SOURCE_DIR`：项目的源代码根目录，即包含顶层 CMakeLists.txt 文件的目录。
* `CMAKE_BINARY_DIR`：项目的二进制根目录，即当前正在执行 CMake 命令的目录。
* `EXECUTABLE_OUTPUT_PATH`：指定可执行文件的输出目录。
* `LIBRARY_OUTPUT_PATH`：指定库文件的输出目录。

## 2.4 常用函数
### 1.指定使用的CMake的最低版本
```CMake
cmake_minimum_required(VERSION 3.15)
```

### 2.定义工程名称
```CMake
project(project-name)
```

### 3.生成可执行程序
```CMake
add_executable(可执行程序名 源文件名称)

# 示例：（源文件可以是多个，之间用空格或者；间隔）
add_executable(app add.c div.c main.c mult.c sub.c)
add_executable(app add.c;div.c;main.c;mult.c;sub.c)
```

### 4.定义变量
```CMake
# VAR:变量名    VALUE:变量值
set(VAR VALUE)

# 示例：
set(SRC add.c div.c main.c mult.c sub.c)
add_executable(app ${SRC})
```

### 5.指定只用的C++标准
```CMake
# 方法1：在SHELL中使用g++指令的时候
$ g++ *.cpp -std=c++11 -o app

# 方法2：在CMakeLists.txt中通过set命令指定
set(CMAKE_CXX_STANDARD 11)

# 方法3：在执行cmake命令的时候指定
$ cmake CMakeLists.txt文件路径 -DCMAKE_CXX_STANDARD=11
```

### 6.指定可执行文件输出的路径
```CMake
# 如果路径中的子目录不存在，会自动生成
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
```

### 7.查找某个路径下的所有源文件
```CMake
# dir:要搜索的目录
# variable:将搜索到的源文件列表存储到改变量中
aux_source_directory(<dir> <variable>)

# 示例：
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRC)
add_executable(app ${SRC})
```

### 8.根据指定条件搜索文件
```CMake
# GLOB:将指定目录下搜索到的满足条件的所有文件名生成一个列表，并将其存储到变量中。
# GLOB_RECURSE:递归搜索指定目录，将搜索到的满足条件的文件名生成一个列表，并将其存储到变量中。
file(GLOB/GLOB_RECURSE 变量名 要搜索的文件路径和文件名)

# 示例：
file(GLOB MAIN_SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
file(GLOB MAIN_HEAD ${CMAKE_CURRENT_SOURCE_DIR/include/*.h})
```

### 9.包含头文件
```CMake
# head-path:头文件所在路径
include_directories(head-path)

# 示例：
include_directories(${PROJECT_SOURCE_DIR}/include)
```

### 10.制作静态库
```CMake
add_library(库名称 STATIC 源文件)

#示例：(最终会生成对应的静态库文件 libcalc.a)
# 搜索源文件
file(GLOB SRC ${PROJECT_SOURCE_DIR}/src/*.cpp)

# 包含头文件
include_directories(${PROJECT_SOURCE_DIR}/include)

# 指定静态库输出位置
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)

# 生成静态库
add_library(calc STATIC ${SRC})
```

### 11.制作动态库
```CMake
add_library(库名称 SHARED 源文件)

#示例：(最终会生成对应的静态库文件 libcalc.so)
file(GLOB SRC ${PROJECT_SOURCE_DIR}/src/*.cpp)
include_directories(${PROJECT_SOURCE_DIR}/include)
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
add_library(calc SHARED ${SRC})
```

### 12.指定静态库/动态库的输出路径
**方式1-适用于动态库**
由于在Linux下生成的动态库默认是有可执行权限的，所以可以使用宏`EXECUTABLE_OUTPUT_PATH`来指定动态库的输出路径。
```CMake
# 示例：（最终会在./lib文件夹下生成动态库）
include_directories(${PROJECT_SOURCE_DIR}/include)
file(GLOB SRC ${PROJECT_SOURCE_DIR}/src/*.cpp)

#设置动态库生成路径
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
add_library(calc SHARED ${SRC})
```

**方式2-适用于静态库和动态库**
```CMake
include_directories(${PROJECT_SOURCE_DIR}/include)
file(GLOB SRC ${PROJECT_SOURCE_DIR}/src/*.cpp)

#设置静态库/动态库生成路径
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)

#在指定文件夹下生成静态库
add_library(calc STATIC ${SRC})

#在指定文件夹下生成动态库
add_library(calc SHARED ${SRC})
```

### 13. 链接静态库
```CMake
# 指定静态库的路径
link_directories(<lib-path>)

# 链接静态库 
link_libraries(<static-lib>)
```
`link_libraries`用于设置全局链接库，这些库会链接到之后定义的所有目标上。指定要链接的静态库名字：
* 可以是全名 libxxx.a
* 也可以是掐头（lib）去尾（.a）之后的名字 xxx

```CMake
# 示例：
# 搜索指定目录下源文件
file(GLOB SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
# 包含头文件路径
include_directories(${PROJECT_SOURCE_DIR}/include)
# 包含静态库路径
link_directories(${PROJECT_SOURCE_DIR}/lib)
# 链接静态库
link_libraries(calc)
# 指定静态库输出位置
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
# 生成可执行文件 app
add_executable(app ${SRC})
```

### 14.链接动态库
```CMake
# 指定动态库的路径
link_directories(<lib-path>)

# 链接动态库 
target_link_libraries(<target> <shared-lib>)
```
`target_link_libraries`用于指定一个目标在编译时需要链接哪些库。它支持指定库的名称，路径以及链接库的顺序。
`target`：链接动态库之后目标文件
`shared-lib`：需要链接的库的名称
* PUBLIC：用于传递性的链接
* PRIVATE：用于非传递性的链接
* INTERFACE：用于定义接口，这些接口不会链接到声明它们的库或可执行文件，但会链接到依赖它们的其他目标。

```CMake
# 示例：
# 搜索指定目录下源文件
file(GLOB SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
# 包含头文件路径
include_directories(${PROJECT_SOURCE_DIR}/include)
# 包含动态库路径
link_directories(${PROJECT_SOURCE_DIR}/lib)
# 指定静态库输出位置
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
# 生成可执行文件 app
add_executable(app ${SRC})
# 链接动态库
target_link_libraries(app calc)
```

### 15.添加子目录
Linux的目录是树状结构，所以嵌套的 CMake 也是一个树状结构，最顶层的 CMakeLists.txt 是根节点，其次都是子节点。
* 根节点CMakeLists.txt中的变量全局有效
* 父节点CMakeLists.txt中的变量可以在子节点中使用
* 子节点CMakeLists.txt中的变量只能在当前节点中使用

```CMake
# source_dir：指定子目录。
# binary_dir：指定了输出文件的路径，一般不需要指定。
# EXCLUDE_FROM_ALL：一般不需要设置，忽略。
add_subdirectory(source_dir [binary-dir] [EXCLUDE_FROM_ALL])

#示例：
add_subdirectory(calc)
```

### 15.日志
```CMake
message([STATUS|WARNING|AUTHOR_WARNING|FATAL_ERROR|SEND_ERROR] "message to display")
```
* (无)：重要消息
* STATUS：非重要消息
* WARNING：CMake警告，会继续执行
* AUTHOR_WARNING：CMake警告，会继续执行
* SEND_ERROR：CMake 错误，继续执行，但是会跳过生成的步骤
* FATAL_ERROR：CMake 错误, 终止所有处理过程

CMake的命令行工具会在stdout上显示(无)或STATUS消息，在stderr上显示其他所有消息。CMake的GUI会在它的log区域显示所有消息。
```CMake
# 示例：
# 输出一般日志信息
message(STATUS "source path: ${PROJECT_SOURCE_DIR}")
# 输出警告信息
message(WARNING "source path: ${PROJECT_SOURCE_DIR}")
# 输出错误信息
message(FATAL_ERROR "source path: ${PROJECT_SOURCE_DIR}")
```

### 16.变量操作
1.使用set拼接
将从第二个参数开始往后所有的字符串进行拼接，最后将结果存储到第一个参数中，如果第一个参数中原来有数据会对原数据就行覆盖。
```CMake
set(变量名1 ${变量名1} ${变量名2} ...)
```

2.获取list的长度
```CMake
# LENGTH：关键字
# list：当前操作列表
# output-variable：新创建的变量，用于存储列表长度
list(LENGTH <list> <output variable>)
```

3.读取列表中指定索引的的元素，可以指定多个索引
```CMake
# element-index：列表元素的索引，索引0为列表第一个元素；索引也可以是负数，-1表示列表的最后一个元素，-2表示列表倒数第二个元素；
# output-variable：新创建的变量，存储指定索引元素的返回结果，也是一个列表
list(GET <list> <element-index> <output-variable>)
```

4.将列表中的元素用连接符（字符串）连接起来组成一个字符串
```CMake
# glue：指定的连接符（字符串）
list (JOIN <list> <glue> <output-variable>)
```

5.查找列表是否存在指定的元素，若果未找到，返回-1
```CMake
# output-variable：如果找到则为索引值，否则为-1
list(FIND <list> <value> <output-variable>)
```

6.将元素追加到列表中
```CMake
list (APPEND <list> <element>)
```

7.在list中指定的位置插入若干元素
```CMake
list(INSERT <list> <element-index> <element>)
```

8.将元素插入到列表的0索引位置
```CMake
list (PREPEND <list> <element>)
```

9.将列表中最后元素移除
```CMake
list (POP_BACK <list> <out-var>)
```

10.将列表中第一个元素移除
```CMake
list (POP_FRONT <list> <out-var>)
```

11.将指定的元素从列表中移除
```CMake
list (REMOVE_ITEM <list> <value>)
```

12.将指定索引的元素从列表中移除
```CMake
list (REMOVE_AT <list> <index>)
```

13.移除列表中的重复元素
```CMake
list (REMOVE_DUPLICATES <list>)
```

14.列表翻转
```CMake
list(REVERSE <list>)
```

15.列表排序
```CMake
list (SORT <list> [COMPARE <compare>] [CASE <case>] [ORDER <order>])
```
COMPARE：指定排序方法。有如下几种值可选
* STRING：按照字母顺序进行排序，为默认的排序方法
* FILE_BASENAME：如果是一系列路径名，会使用basename进行排序
* NATURAL：使用自然数顺序排序

CASE：指明是否大小写敏感。有如下几种值可选：
* SENSITIVE: 按照大小写敏感的方式进行排序，为默认值
* INSENSITIVE：按照大小写不敏感方式进行排序

ORDER：指明排序的顺序。有如下几种值可选：
* ASCENDING：按照升序排列，为默认值
* DESCENDING：按照降序排列

## 2.5 宏定义
在进行程序测试的时候，我们可以在代码中添加一些宏定义，通过这些宏来控制这些代码是否生效：
```C
#include <stdio.h>
#define NUMBER  3
int main()
{
    int a = 10;
#ifdef DEBUG
    printf("this is debug place\n");
#endif
    for(int i=0; i<NUMBER; ++i)
    {
        printf("hello, world\n");
    }
    return 0;
}
```
为了测试更加灵活，一般不在代码中定义这个宏，而是在测试的时候把这个宏定义出来。
```CMake
# 在gcc/g++命令中定义
$ gcc main.c -DDEBUG -o app

# 在CMakeLists.txt文件中定义
add_definitions(-DDEBUG)
add_executable(app ./main.c)
```

# 生成能够gdb调试的可执行文件
在CMakeLists.txt中加入：
```CMake
SET(CMAKE_BUILD_TYPE "Debug")
SET(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g2 -ggdb")
SET(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")
```
CMAKE\_BUILD\_TYPE是CMake构建系统使用的一个变量，用于指定编译时的优化级别和调试信息的详细程度，常用的值有:
* Debug
* Release
* RelWithDebInfo
* MinSizeRel
当这个变量值为 Debug 的时候,CMake 会使用变量 CMAKE\_CXX\_FLAGS\_DEBUG 和 CMAKE\_C\_FLAGS\_DEBUG 中的字符串作为编译选项生成 Makefile

# Reference
[大丙老师的 CMake 保姆级教程-上](https://subingwen.cn/cmake/CMake-primer/)
[大丙老师的 CMake 保姆级教程-下](https://subingwen.cn/cmake/CMake-advanced/)
