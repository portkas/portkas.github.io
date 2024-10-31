---
title: Anaconda
categories:
    - 机器学习
---

<!-- more -->
# 常用指令
## 命令行窗口
```
# 查看版本号
> conda --version

# 查看目前的镜像
> conda config 

# 添加路径
> conda config --add channels http://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
> conda config –-add channels http://mirrors.ustc.edu.cn/anaconda/pkgs/free/
> conda config --add channels http://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
> conda config --set show_channel_urls yes

# 升级工具包
> conda upgrade --all
```

## Anaconda Prompt
```
# 创建虚拟环境
> conda create -n <env-name> python=3.6

# 列出所有可用的conda环境
> conda info --envs

# 进入虚拟环境
> activate <env-name>

# 退出虚拟环境
> deactivate

# 安装package
> conda install <package-name>

# 查看当前环境下安装的packages
> conda list

# 安装package
> pip install -i http://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn  matplotlib

```

## ps
Anaconda Prompt可以看作是命令行窗口（CMD）的增强版，专门为Anaconda用户设计，以支持Python开发和数据科学工作。
* Anaconda Prompt完全兼容CMD中的所有命令。
* Anaconda Prompt提供了conda命令，用于管理Anaconda环境和包。
* Anaconda Prompt预装了许多数据科学和机器学习相关的库
* Anaconda Prompt允许用户创建、激活和删除不同的Python环境（称为conda环境）

# reference
[anaconda安装](https://blog.csdn.net/Inochigohan/article/details/120400990)
[清华镜像源](https://blog.csdn.net/qq_39220334/article/details/121961742)
[conda常用命令](https://www.cnblogs.com/lab-zj/p/16975410.html)
[pip安装package](https://blog.csdn.net/JineD/article/details/124774570)