---
title: gtest入门-1
categories:
	- gtest
---
# 安装

```bash
$ git clone https://github.com/google/googletest.git
$ cd googletest
$ mkdir build
$ cd build
$ cmake ..
$ make
$ sudo make install
```

<!-- more -->

# 使用

## 测试代码

```cpp
#include <gtest/gtest.h>

int Foo(int a,int b)
{
   if(0 == a||0 == b)
   throw "don't do that";
   int c = a%b;
   if (0 == c)
  {
     return b;
  }
  return Foo(b,c);
}
  
TEST(FooTest,HandleNoneZeroInput)
{
   EXPECT_EQ(2,Foo(4,10));
   EXPECT_EQ(6,Foo(30,18));
}
int main(int argc,char*argv[])
{
   testing::InitGoogleTest(&argc,argv);
   return RUN_ALL_TESTS();
}
```



## 编译运行

```bash
$ g++ -o app first.cpp -lgtest -lpthread -std=c++14
$ ./app 
[==========] Running 1 test from 1 test suite.
[----------] Global test environment set-up.
[----------] 1 test from FooTest
[ RUN      ] FooTest.HandleNoneZeroInput
[       OK ] FooTest.HandleNoneZeroInput (0 ms)
[----------] 1 test from FooTest (0 ms total)

[----------] Global test environment tear-down
[==========] 1 test from 1 test suite ran. (0 ms total)
[  PASSED  ] 1 test.
```


## 使用流程

1. 头文件gtest/gtest.h；
2. 使用TEST宏定义测试，两个参数：测试用例名，测试名，这两个参数只是起到提示作用；
3. 在main中调用RUN_ALL_TESTS()；



# 命令行参数

* **`--gtest_list_tests`** ：当使用这个参数时，gtest 将不会执行任何测试用例，而是列出所有可用的测试用例名称。
* **`--gtest_filter=<test_filters>`** ：允许对执行的测试用例进行过滤。`<test_filters>` 可以是一个或多个测试用例名称的模式，支持通配符（如 `*` 和 `?`）。例如，`--gtest_filter=*DeathTest*` 将运行所有名称中包含 "DeathTest" 的测试用例。
* **`--gtest_also_run_disabled_tests`** ：默认情况下，gtest 会跳过那些被标记为 `DISABLED_` 的测试用例。使用这个参数可以强制执行这些被禁用的测试用例。
* **`--gtest_repeat=<count>`** ：设置测试用例重复运行的次数。`<count>` 是一个正整数，表示每个测试用例将被重复执行的次数。例如，`--gtest_repeat=3` 将使每个测试用例运行三次。
* **`--gtest_color=(yes|no|auto)`** ：控制命令行输出是否使用颜色。`yes` 表示始终使用颜色，`no` 表示不使用颜色，`auto`（默认）表示根据终端是否支持颜色自动决定。
* **`--gtest_print_time`** ：当启用时，gtest 将在输出中打印每个测试用例的执行时间。默认情况下，gtest 不打印每个测试用例的执行时间。
* **`--gtest_output=xml[:DIRECTORY_PATH|:FILE_PATH]`** ：将测试结果输出到一个 XML 文件中。如果不指定文件路径，gtest 将在当前目录下生成一个名为 `test_detail.xml` 的文件，并在每次运行时以数字后缀的方式创建新文件，以避免覆盖。
* **`--gtest_break_on_failure`** ：在调试模式下，当测试失败时，gtest 将中断执行。
* **`--gtest_throw_on_failure`** ：当测试失败时，gtest 将抛出一个 C++ 异常。
* **`--gtest_catch_exceptions`** ：控制 gtest 是否捕捉测试执行过程中抛出的异常。默认情况下，gtest 不捕捉异常。这个参数主要在 Windows 平台上有效。

使用方法：

```bash
$ ./app --gtest_list_tests
FooTest.
  HandleNoneZeroInput



$ ./app --gtest_repeat=3

Repeating all tests (iteration 1) . . .

[==========] Running 1 test from 1 test suite.
[----------] Global test environment set-up.
[----------] 1 test from FooTest
[ RUN      ] FooTest.HandleNoneZeroInput
[       OK ] FooTest.HandleNoneZeroInput (0 ms)
[----------] 1 test from FooTest (0 ms total)

[==========] 1 test from 1 test suite ran. (0 ms total)
[  PASSED  ] 1 test.

Repeating all tests (iteration 2) . . .

[==========] Running 1 test from 1 test suite.
[----------] 1 test from FooTest
[ RUN      ] FooTest.HandleNoneZeroInput
[       OK ] FooTest.HandleNoneZeroInput (0 ms)
[----------] 1 test from FooTest (0 ms total)

[==========] 1 test from 1 test suite ran. (0 ms total)
[  PASSED  ] 1 test.

Repeating all tests (iteration 3) . . .

[==========] Running 1 test from 1 test suite.
[----------] 1 test from FooTest
[ RUN      ] FooTest.HandleNoneZeroInput
[       OK ] FooTest.HandleNoneZeroInput (0 ms)
[----------] 1 test from FooTest (0 ms total)

[----------] Global test environment tear-down
[==========] 1 test from 1 test suite ran. (0 ms total)
[  PASSED  ] 1 test.
```


# 断言

gtest使用一系列断言的宏来检查是否符合预期，主要分为两类：ASSERT和EXPECT

* ASSERT：不通过的时候会认为是一个fatal的错误，退出当前函数；
* EXPECT：失败的话会继续运行当前函数，所以对于函数内几个失败可以同时报告出来；

### 基础断言

| ASSERT                   | EXPECT                   | Verifiles          |
| ------------------------ | ------------------------ | ------------------ |
| ASSERT_TRUE(condition);  | EXPECT_TRUE(condition);  | condition is true  |
| ASSERT_FALSE(condition); | EXPECT_FALSE(condition); | condition is false |


### 数值比较

| ASSERT                 | EXPECT                 | Verifiles    |
| ---------------------- | ---------------------- | ------------ |
| ASSERT_EQ(val1, val2); | EXPECT_EQ(val1, val2); | val1 == val2 |
| ASSERT_NE(val1, val2); | EXPECT_NE(val1, val2); | val1 != val2 |
| ASSERT_LT(val1, val2); | EXPECT_LT(val1, val2); | val1 < val2  |
| ASSERT_LE(val1, val2); | EXPECT_LE(val1, val2); | val1 <= val2 |
| ASSERT_GT(val1, val2); | EXPECT_GT(val1, val2); | val1 > val2  |
| ASSERT_GE(val1, val2); | EXPECT_GE(val1, val2); | val1 >= val2 |


### 字符串比较

| ASSERT                        | EXPECT                        | Verifiles                        |
| ----------------------------- | ----------------------------- | -------------------------------- |
| ASSERT_STREQ(str1, str2);     | EXPECT_STREQ(str1, str2);     | same content                     |
| ASSERT_STRNE(str1, str2);     | EXPECT_STREQ(str1, str2);     | different content                |
| ASSERT_STRCASEEQ(str1, str2); | EXPECT_STRCASEEQ(str1, str2); | same content, ignoring case      |
| ASSERT_STRCASENE(str1, str2); | EXPECT_STRCASEEQ(str1, str2); | different content, ignoring case |
