---
title: 协程-yield
date: 2025-8-8 10:00:00
categories:
- 协程
- yield
---
## 1. [Python进阶必看：深入解析yield的强大功能](https://segmentfault.com/a/1190000045256304)

1. yield用来创建生成器函数；
2. 生成器函数特点
   * 惰性求值：生成器在每次调用时生成一个值，而不是一次性生成所有值，这可以节省内存。
   * 状态保持：生成器函数会记住上一次返回值时的状态，下一次迭代会从上次停止的地方继续执行。
   * 无限序列：生成器可以用于生成无限序列，而不会占用大量内存。
3. 使用yield实现协程，协程是更高级的生成器，允许在生成值的同时接收外部数据。使用 `send`方法可以向生成器发送数据，并在生成器内部使用 `yield`表达式接收数据。

```python
def simple_generator():
    yield 1
    yield 2
    yield 3

# 使用生成器
gen = simple_generator()

print(next(gen))  # 输出: 1
print(next(gen))  # 输出: 2
print(next(gen))  # 输出: 3
print(next(gen))  # StopIteration:
```


## 2. [Python yield 解析：原理、示例与 send 方法](https://www.xxrbear.cn/posts/tech/python/yield/)

1. yield作用
   * 暂停函数执行：当函数执行到 `yield` 语句时，函数会暂停执行，并将 `yield` 后面的值返回给调用者
   * 保存函数状态：函数的状态（包括局部变量、指令指针等）会被保存下来，下次调用时可以从暂停的地方继续执行；
   * 生成值：每次调用生成器的 `next()` 方法或使用 `for` 循环时，生成器会从上次暂停的地方继续执行，直到遇到下一个 `yield` 或函数结束；
2. send作用
   * 传递值：`send`方法可以将一个值传递给生成器，这个值会成为当前暂停的 `yield` 表达式的结果；
   * 恢复执行：`send`方法会从生成器暂停的地方继续执行，直到遇到下一个 `yield` 或生成器结束；
   * 返回值：`send`方法会返回生成器通过 `yield`生成的下一个值；

```python
def my_generator():
    print("Start")
    res1 = yield 1
    print(res1)
    res2 = yield 2
    print(res2)
    print("End")

gen = my_generator()  # 创建生成器对象，但不会执行
print(gen.send(None))
print(gen.send("Fuck"))
print(gen.send("Fuck"))

# Start
# 1
# Fuck
# 2
# Fuck
# End
# StopIteration:
```

> 注意，你不能一开始就使用 send 方法发送非空值，这会导致抛出异常。
>
> 错误原因：生成器还没有开始执行 yield，无法接收 send("Func") 传来的值；


## 3. [深入理解 Python 中的生成器与yield：从基础到高级应用](https://www.cnblogs.com/tekin/p/18747562)

1. 生成器作为一种特殊的迭代器，借助 `yield` 语句实现了惰性求值;
2. 与普通迭代器不同的是，生成器无需显式地定义 `__iter__()`和 `__next__()`方法，而是巧妙地通过 `yield` 语句来创建。
3. yield语句工作原理：
   * 当生成器函数执行到 `yield` 语句时，会暂时停止执行，并将 `yield` 后面的值返回给调用者。
   * 与此同时，函数的当前状态（包括局部变量的值等信息）会被妥善保存下来。
   * 当下一次调用生成器的 `__next__()` 方法时，函数会从上次暂停的位置继续执行，周而复始，直到遇到下一个 `yield` 语句或者函数执行完毕。
4. 生成器表达式是一种极为简洁的创建生成器的方式，它与列表推导式在形式上颇为相似，但使用的是圆括号而非方括号。生成器表达式同样遵循惰性求值原则，只有在需要时才会生成下一个值；

```python
# 列表推导式
list_comp = [i for i in range(5)]
print(list_comp)  # 输出: [0, 1, 2, 3, 4]
 
# 生成器表达式
gen_expr = (i for i in range(5))
print(gen_expr)  # 输出: <generator object <genexpr> at 0x...>
 
# 遍历生成器表达式
for num in gen_expr:
    print(num)  # 依次输出: 0 1 2 3 4
```

5. 在 Python 编程里，`yield` 语句还能用于实现协程。协程是一种比线程更加轻量级的并发编程模型，通过 `yield` 语句可以灵活地实现协程的暂停和恢复操作，从而实现高效的并发处理。

```python
# import pdb
# pdb.set_trace()

def coroutine_example():
    print("协程开始")
    while True:
        value = yield 1
        print(f"接收到的值: {value}")

# 这里是讲函数赋值给coro，但是并没有启动这个函数；
coro = coroutine_example()

# 启动函数，所以会有返回值，把1返回，赋值给a；
a = next(coro)
print(a)

b = coro.send(10)
print(b)

c = coro.send(20)  
print(c)

coro.close()
```

6. `yield from` 后面可以跟一个可迭代对象（如生成器、列表等），它会将可迭代对象中的元素逐个 `yield` 出来;

```python
def sub_generator():
    yield 1
    yield 2
 
def main_generator():
    yield from sub_generator()
    yield 3
 
gen = main_generator()
for num in gen:
    print(num)  # 依次输出: 1 2 3
```

7. 注意事项
   * 在使用生成器时，务必注意处理 `StopIteration` 异常。当生成器耗尽时，调用 `next()` 函数会引发该异常。可以使用 `try-except` 语句来捕获和处理该异常，以确保程序的健壮性。
   * 在使用 `yield` 实现协程时，需要先调用 `next()` 函数或 `send(None)` 来启动协程。这是因为协程开始时需要先执行到第一个 `yield` 语句才能暂停，从而进入可接收数据的状态。
8. 数据处理：在处理大规模数据文件时，使用生成器可以避免将整个文件加载到内存中，从而有效节省内存资源。

```python
def read_large_file(file_path):
    with open(file_path, 'r') as file:
        for line in file:
            yield line
 
# 处理大文件
file_path = 'large_file.txt'
gen = read_large_file(file_path)
for line in gen:
    # 处理每一行数据
    print(line.strip())
```

9. 在网络爬虫领域，使用生成器可以逐个处理爬取到的网页，而不是一次性将所有网页存储在内存中，这对于处理大量网页数据尤为重要。

```python
import requests
 
def fetch_pages(urls):
    for url in urls:
        response = requests.get(url)
        if response.status_code == 200:
            yield response.text
 
# 爬取多个网页
urls = ['https://example.com', 'https://python.org']
page_generator = fetch_pages(urls)
for page in page_generator:
    # 处理每个网页内容
    print(page[:100])
```

## 4. 总结

1. yield在我看来主要有两个关键的点：
   * 执行到yield的时候，可以把他看作return，并且返回yield后面紧跟的值，但是和return不同的是，yield处理之后，再次通过send或者next函数进入该函数时，会接着执行yield后面的代码，而不是说，从头开始执行；
   * 可以通过next，send再次进入生成器，接着yield之后的代码开始执行，sand可以传输数据，给yield执行之后的返回值；
2. 语法：
   * func.send();
   * next(func);
   * for
