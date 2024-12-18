---
title: C++性能测试工具: google benchmark 1
categories:
	- benchmark
---
# 安装

```bash
$ sudo apt install g++ cmake
git clone https://github.com/google/benchmark.git
git clone https://github.com/google/googletest.git benchmark/googletest
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE ../benchmark
make -j4
sudo make install
```

<!-- more -->

# 使用

## 测试代码

```cpp
#include <benchmark/benchmark.h>
#include <array>
 
constexpr int len = 6;
 
// constexpr function具有inline属性，你应该把它放在头文件中
constexpr auto my_pow(const int i)
{
    return i * i;
}
 
// 使用operator[]读取元素，依次存入1-6的平方
static void bench_array_operator(benchmark::State& state)
{
    std::array<int, len> arr;
    constexpr int i = 1;
    for (auto _: state) {
        arr[0] = my_pow(i);
        arr[1] = my_pow(i+1);
        arr[2] = my_pow(i+2);
        arr[3] = my_pow(i+3);
        arr[4] = my_pow(i+4);
        arr[5] = my_pow(i+5);
    }
}
BENCHMARK(bench_array_operator);
 
// 使用at()读取元素，依次存入1-6的平方
static void bench_array_at(benchmark::State& state)
{
    std::array<int, len> arr;
    constexpr int i = 1;
    for (auto _: state) {
        arr.at(0) = my_pow(i);
        arr.at(1) = my_pow(i+1);
        arr.at(2) = my_pow(i+2);
        arr.at(3) = my_pow(i+3);
        arr.at(4) = my_pow(i+4);
        arr.at(5) = my_pow(i+5);
    }
}
BENCHMARK(bench_array_at);
 
// std::get<>(array)是一个constexpr function，它会返回容器内元素的引用，并在编译期检查数组的索引是否正确
static void bench_array_get(benchmark::State& state)
{
    std::array<int, len> arr;
    constexpr int i = 1;
    for (auto _: state) {
        std::get<0>(arr) = my_pow(i);
        std::get<1>(arr) = my_pow(i+1);
        std::get<2>(arr) = my_pow(i+2);
        std::get<3>(arr) = my_pow(i+3);
        std::get<4>(arr) = my_pow(i+4);
        std::get<5>(arr) = my_pow(i+5);
    }
}
BENCHMARK(bench_array_get);
 
BENCHMARK_MAIN();
```

上述代码使用Google Benchmark库对 C++ 中访问和更新 `std::array` 元素的不同方法进行性能测试。

1. 基准测试函数：
   * `bench_array_operator`：使用operator[]访问和更新数组
   * `bench_array_at`：使用arr.at()方法访问和更新数组
   * `bench_array_get`：使用std::get<>模板函数访问和更新数组
2. 基准测试注册：
   * 使用 `BENCHMARK(bench_array_operator);`注册每个基准测试函数，从而Google Benchmark工具知道需要运行哪些测试。
3. 程序入口函数：
   * 使用 `BENCHMARK_MAIN()`定义程序入口函数，并初始化Google Benchmark库，它会自动运行被注册的所有基准测试。

## 编译运行

```cpp
$ g++ -Wall -std=c++14 arrayTest.cpp -pthread -lbenchmark
$ ./a.out
2024-12-17T13:04:52+08:00
Running ./a.out
Run on (12 X 2995.2 MHz CPU s)
CPU Caches:
  L1 Data 48 KiB (x6)
  L1 Instruction 32 KiB (x6)
  L2 Unified 1280 KiB (x6)
  L3 Unified 20480 KiB (x1)
Load Average: 0.31, 0.29, 0.14
---------------------------------------------------------------
Benchmark                     Time             CPU   Iterations
---------------------------------------------------------------
bench_array_operator       18.5 ns         18.5 ns     39134698
bench_array_at             23.3 ns         23.3 ns     31354014
bench_array_get            18.6 ns         18.6 ns     39320276
```

1. 执行日期和时间：

   - "2024-12-17T13:04:52+08:00" 表示基准测试进行的时间以及时区。
2. 系统信息：

   - 测试是在一个拥有12个逻辑CPU，每个运行在2995.2 MHz上的系统上进行的。CPU缓存层次结构如下：
     - L1数据缓存：每个核心48 KiB（共有6个核心）
     - L1指令缓存：每个核心32 KiB（共有6个核心）
     - L2统一缓存：每个核心1280 KiB（共有6个核心）
     - L3统一缓存：共有20480 KiB（这通常是共享缓存）
3. 系统负载：

   - "Load Average: 0.31, 0.29, 0.14" 代表系统在过去1分钟、5分钟和15分钟的平均负载。
4. 基准测试结果：

   - `bench_array_operator`， `bench_array_at` 和 `bench_array_get` 是测试的三个函数，用于访问数组元素。
   - `Time` 和 `CPU` 列显示了执行这些操作的时间。测量值通常为纳秒（ns）。
   - `Iterations` 列显示了在测试过程中运行的迭代次数。

从结果看，`bench_array_operator` 和 `bench_array_get` 的性能较好，执行时间较短，而 `bench_array_at` 的执行时间稍长。
