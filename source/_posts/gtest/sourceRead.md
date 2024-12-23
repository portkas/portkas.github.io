---
title: gtest官方示例代码
categories:
	- gtest
---
# gtest_main

<!-- more -->

## 代码解析

```cpp
#include <cstdio>
#include "gtest/gtest.h"

#if defined(GTEST_OS_ESP8266) || defined(GTEST_OS_ESP32) || (defined(GTEST_OS_NRF52) && defined(ARDUINO)) // ****#if-level-1****
// Arduino-like platforms: program entry points are setup/loop instead of main.

#ifdef GTEST_OS_ESP8266				// ****#ifdef-level-2-1****
extern "C" {
#endif						// ****#endif-level-2-1****

void setup() { testing::InitGoogleTest(); }
void loop() { RUN_ALL_TESTS(); }


#ifdef GTEST_OS_ESP8266				// ****#ifdef-level-2-2****
}
#endif						// ****#endif-level-2-2****

#elif defined(GTEST_OS_QURT)										// ****#elif-level-1****
// QuRT: program entry point is main, but argc/argv are unusable.

GTEST_API_ int main() {
  printf("Running main() from %s\n", __FILE__);
  testing::InitGoogleTest();
  return RUN_ALL_TESTS();
}
#else													// ****#else-level-1****
// Normal platforms: program entry point is main, argc/argv are initialized.

GTEST_API_ int main(int argc, char **argv) {
  printf("Running main() from %s\n", __FILE__);
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

#endif													// ****end-level-1****
```

通过level可以比较清楚的看清逻辑结构：

1. 如果定义了以下宏，则运行下面这部分代码：

   * `GTEST_OS_ESP8266`：表示编译目标是 ESP8266 平台
   * `GTEST_OS_ESP32`：表示编译目标是 ESP32 平台
   * `(defined(GTEST_OS_NRF52) && defined(ARDUINO))`：表示编译目标是 Nordic nRF52 系列的设备，并且是在 Arduino 环境下编译

```cpp
#ifdef GTEST_OS_ESP8266				// ****#ifdef-level-2-1****
extern "C" {
#endif						// ****#endif-level-2-1****

void setup() { testing::InitGoogleTest(); }
void loop() { RUN_ALL_TESTS(); }


#ifdef GTEST_OS_ESP8266				// ****#ifdef-level-2-2****
}
#endif
```

2. 如果定义了 `GTEST_OS_QURT` 宏，即再QuRT操作系统上编译运行，则执行下面这部分代码：

```cpp
GTEST_API_ int main() {
  printf("Running main() from %s\n", __FILE__);
  testing::InitGoogleTest();
  return RUN_ALL_TESTS();
}
```

3. 如果是除此之外的其他平台则运行下面这部分代码：

```cpp
GTEST_API_ int main(int argc, char **argv) {
  printf("Running main() from %s\n", __FILE__);
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```


## 进一步解析

1. 根据注释，对于类似Arduino平台，程序的入口点是setup/loop，而不是main，所以需要单独编写；
   1. 在setup函数中初始化；
   2. 在loop函数中运行所有测试；
2. 但是对于ESP8266平台，需要使用C链接，除了它之外的另外三个则不需要，所以单独将它进行C链接的"开关"打开；
3. 对于QuRT平台，程序的入口点是main，但是不能用argc/argv；
4. 对于其他的普通平台如Linux，程序的入口点是main，并且可以使用argc/argv;
