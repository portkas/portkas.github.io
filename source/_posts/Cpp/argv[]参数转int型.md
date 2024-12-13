---
title: argv[]参数转int型
categories:
    - C
---
在C/C++中，argv[]是一个字符数组（char*），保存了从命令行传递该程序的阐述。

<!-- more -->

# 使用atoi()函数

```C
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
  if(argc > 1){
     int num = atoi(argv[1]);
     printf("%d\n", num);
  }else{
     printf("please input one argv!\n");
  }
  return 0;
}

```

# 使用strtol()函数

```C
#include <stdio.h>
#include <stdlib.h>  // 包含 strtol 函数

int main(int argc, char *argv[]) {
    if (argc > 1) {
        long num = strtol(argv[1], NULL, 10);  // 将 argv[1] 转换为 long 类型，基数为10
        if (*end == '\0') {
            printf("输入的数字是: %ld\n", num);
        } else {
            printf("输入的参数不是有效的数字！\n");
        }
    } else {
        printf("请提供一个数字参数！\n");
    }
    return 0;
}
```

# 使用sscanf()函数

```C
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc > 1) {
        int num;
        if (sscanf(argv[1], "%d", &num) == 1) {  // 将 argv[1] 转换为 int 类型
            printf("输入的数字是: %d\n", num);
        } else {
            printf("输入的参数不是有效的数字！\n");
        }
    } else {
        printf("请提供一个数字参数！\n");
    }
    return 0;
}
```

# 三种方法对比

atoi()：简单快捷，但无法检测错误输入，使用时需要确保输入是有效的数字，否则返回 0。
strtol()：推荐用于更加健壮的转换，它允许处理错误输入并支持不同进制数。
sscanf()：灵活性较高，可以处理多种格式，适用于需要从字符串中解析多个值的场景。
