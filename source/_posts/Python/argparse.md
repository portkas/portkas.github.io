---
title: 语法-argparse
date: 2025-8-14 10:00:00
categories:
- 语法
- argparse
---

## 1. 核心概念

### 1.1 ArgumentParser 对象

用于创建命令行解析器：

```
parser = argparse.ArgumentParser(
    description='程序描述',  # 程序描述
    epilog='结尾说明',       # 帮助信息结尾的说明
    add_help=True           # 是否自动添加 -h/--help 选项
)
```

### 1.2 添加参数

#### 情况1：没有前缀参数

没有前缀的参数，必须要提供：

```python
parser.add_argument('filename', help='输入文件名')
```

#### 情况2：有前缀参数

有前缀的参数，选择性提供：

```python
parser.add_argument('-o', '--output', help='输出文件名')
```

### 1.3 参数类型

可以指定参数类型：

```python
parser.add_argument('--count', type=int, help='整数参数')
```

### 1.4 默认值

可以为参数添加默认值：

```python
parser.add_argument('--verbose', default=False, action='store_true', help='详细模式')
```

### 1.5 必须参数

标记参数为必须：

```python
parser.add_argument('--required', required=True, help='必需参数')
```


## 2. 使用示例

```python
def main():
    parser = argparse.ArgumentParser(description='日志异常分析工具')
    parser.add_argument('--log_file', default='vllm.log', help='要分析的日志文件路径')
    parser.add_argument('--csv_file', default='output.csv', help='要标记的CSV文件路径')
    parser.add_argument('--output_csv', default='marked_issues.csv', help='输出标记后的CSV文件路径')
    args = parser.parse_args()
```

1. 创建一个ArgumentParser对象；
2. 使用add_argument添加参数；
3. 使用命令行运行： `python script.py --log_file mylog.log --csv_file data.csv`
