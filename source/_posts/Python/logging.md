---
title: 日志-基础用法
date: 2025-8-11 10:00:00
categories:
- 日志
- 基础语法
---

## 1. [官方文档](https://docs.python.org/zh-cn/3/library/logging.html)

概述：

1. `logging.getLogger(name)`
   * 模块级别函数，具备层级关系；
   * 用于获取或者创建日志记录器；
   * 可以传入的属性
     * name
     * level
     * parent
     * propagate
     * handlers
2. 日志级别
   * NOTSET
   * DEBUG
   * INFO
   * WARNING
   * ERROR
   * CRI
3. 记录器对象
4. 处理器对象
5. 格式器对象
6. 过滤器对象
7. LoggerAdapter对象


## 2. [Python Logging使用指南](https://www.cnblogs.com/python-miao/p/13807126.html)

### logging与print区别

print 语句用于向 stdout（标准输出）写入有用的信息或程序需要输出的信息。然而 Logging 将这些信息写入 stderr（标准错误输出）。

### 配置logger（记录器）参数

```
import logging

logging.basicConfig(filename='program.log', filemode='w', level=logging.DEBUG)
logging.warning('You are given a warning!')
```

1. 向 program.log 文件输出日志
2. filemode='w' 表示需要打开一个新文件并覆盖原来的内容；
3. 该参数默认设置为 'a'，此时会打开相应文件，并追加日志内容；
4. 当设置 level 为  INFO ，程序就不会输出 DEBUG 级别的日志。
5. 需要设置 'verbose=debug' 才能获取一些debug参数。日志等级默认为  INFO 。

### 创建日志处理器

```python
import logging

logger = logging.getLogger("My Logger")
logger.setLevel(logging.DEBUG)

console_handler = logging.StreamHandler()
file_handler = logging.FileHandler('file.log', mode='w')
console_handler.setLevel(logging.INFO)
file_handler.setLevel(logging.DEBUG)

logger.addHandler(console_handler)
logger.addHandler(file_handler)
```

1. 通过名称获取到一个 Logger。以此可以在程序的其他任意地方使用同一个 Logger。
2. 把全局的 Logging 等级设为最低的  DEBUG ，这样我们就可以在其他日志处理器中设置任意日志等级。
3. 创建两个日志处理器，分别用于 console 和 file 形式的输出，并设置各自的日志等级。这可以减少控制台输出的开销，转而在文件中输出。这方便了以后的调试。
4. `console_handler = logging.StreamHandler()`
   * 创建标准输出处理器；
   * 默认输出到 sys.stderr（控制台错误流）
5. `file_handler = logging.FileHandler('file.log', mode='w')`
   * 创建文件处理器；
6. `logger.addHandler(console_handler)`
   * 将创建的处理器绑定到记录器。记录器可以绑定多个处理器；
7. 记录器处理
   * 比较日志级别与记录器级别；
   * 所有≥10的消息会被接收
8. 处理器分发
   * 消息发送到所有处理器
   * `console_handler`只处理 ≥ INFO（20）的消息；
   * `file_handler`处理所有 ≥ DEBUG（10）的消息
9. 最终输出
   * DEBUG 消息 → 仅写入 file.log
   * INFO 消息 → 同时输出到控制台和 file.log

### 日志处理器是什么？

日志处理器（Handler）是一个核心组件，负责将日志记录（LogRecord）发送到指定的目的地。简单来说，日志处理器决定了日志的去向和输出方式。

1. **输出目的地管理**：决定日志输出到哪里（控制台、文件、网络等）
2. **级别过滤**：可以单独设置处理器的日志级别
3. **格式控制**：通过关联的格式化器（Formatter）控制日志格式
4. **消息过滤**：可添加自定义过滤器（Filter）进行更复杂的控制

常见处理器类型：

1. StreamHandler
2. FileHandler
3. RotatingFileHandler
4. TimedRotatingFileHandler
5. SMTPHandler
6. SysLogHandler

处理器方法：

1. 设置日志级别
   * `handler.setLevel(logging.INFO)`
2. 设置日志格式
   * `formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')`
   * `handler.setFormatter(formatter)`
3. 添加过滤器
   * `handler.addFilter(MyFilter())`

### 输出日志格式化

```python
console_format = logging.Formatter('%(name)s - %(levelname)s - %(message)s')
file_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

console_handler.setFormatter(console_format)
file_handler.setFormatter(file_format)
```


## 3. [Python的日志工具logging](https://gairuo.com/p/python-logging)

### 3.1 基本概念

1. 日志记录器（Logger）
   * 是程序中用于产生日志信息的对象，通过 `logging.getLogger(name)`获取，日志记录器可以有多个，通过name来区分；
2. 处理器（Handler）
   * 日志记录器并不直接将日志信息输出到目标位置（如控制台或文件），它们将日志传递给处理器。处理器决定了日志输出的具体位置；
   * `StreamHandler`: 将日志输出到控制台；
   * `FileHandler`: 将日志写入文件
   * `RotatingFileHandler`: 将日志写入文件，但会根据大小进行轮转
   * `TimedRotatingFileHandler`: 根据时间进行轮转
3. 格式器（Formatter）
   * 格式器决定了日志信息的具体输出格式。可以包含时间戳、日志级别、日志消息等内容。格式器通过 `logging.Formatter(fmt)` 创建。
4. 日志级别（Level）
   * DEBUG: 调试信息，最详细的日志级别
   * INFO: 普通信息，不用于调试
   * WARNING: 警告信息，表示可能发生的问题
   * ERROR: 错误信息，表示程序遇到了问题
   * CRITICAL: 严重错误，程序可能无法继续运行
5. 过滤器（Filter）
   * 用于更精细地控制哪些日志记录可以通过处理器。例如，可以根据模块名或日志级别来过滤日志。

### 3.2 基本使用

#### 3.2.1 简单日志输出

使用 `logging.basicConfig` 可以快速配置日志系统，定义日志的格式、日志级别等。

```python
import logging

logging.basicConfig(level=logging.INFO)
logging.info("This is an info message")
logging.warning("This is a warning")
```

上述代码，会在控制台输出：

```python
INFO:root:This is an info message
WARNING:root:This is a warning
```

#### 3.2.2 自定义处理器

```python
import logging

# 创建日志器
logger = logging.getLogger('my_logger')
logger.setLevel(logging.DEBUG)

# 创建处理器并设置日志输出到文件
file_handler = logging.FileHandler('app.log')
file_handler.setLevel(logging.ERROR)

# 创建格式器并添加到处理器
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

# 添加处理器到日志器
logger.addHandler(file_handler)

# 记录不同级别的日志
logger.debug("This is a debug message")
logger.error("This is an error message")
```

上述代码，会创建一个处理器，并将ERROR级别及以上日志，输出到app.log文件中；

#### 3.2.3 日志轮转

为了防止日志文件无限增长，可以使用 `RotatingFileHandler` 实现日志轮转。比如，当日志文件达到一定大小时创建一个新文件。

```python
import logging
from logging.handlers import RotatingFileHandler

# 创建 RotatingFileHandler，文件大小超过 1KB 后进行轮转，最多保留 5 个备份文件
handler = RotatingFileHandler('my_log.log', maxBytes=1024, backupCount=5)
logger = logging.getLogger('my_logger')
logger.setLevel(logging.INFO)
logger.addHandler(handler)

for i in range(1000):
    logger.info(f"Log message {i}")
```

#### 3.3.4 基于时间的日志轮转

使用 `TimedRotatingFileHandler` 可以按照时间间隔进行日志轮转。

```python
import logging
from logging.handlers import TimedRotatingFileHandler

# 创建 TimedRotatingFileHandler，每天生成一个新日志文件
handler = TimedRotatingFileHandler('timed_test.log', when='midnight', interval=1, backupCount=7)
logger = logging.getLogger('my_logger')
logger.setLevel(logging.INFO)
logger.addHandler(handler)

logger.info("This is a test message")
```
