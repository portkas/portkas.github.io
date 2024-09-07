---
title: Tmux
categories:
    - Linux
---
# 基本用法
## 安装
```bash
# Ubuntu
$ sudo apt-get install tmux
```
<!--more-->
## 启动和退出
```bash
# 启动
$ tmux

# 退出（或者使用快捷键ctrl+d）
$ exit
```

## 前缀键
Tmux中所有的快捷键都需要通过前缀键唤起，即先按前缀键，再按快捷键，才能生效。默认的前缀键为：ctrl+b

# 会话管理
## 新建会话
第一个启动的Tmux窗口，编号是0, 第二个窗口的编号是1,以此类推。也可以在新建窗口时为窗口指定会话名。
```bash
$ tmux new -s <session-name>
```

## 分离会话
快捷键：ctrl+b d
```bash
$ tmux detach
```

## 查看当前所有Tmux会话
```bash
$ tmux ls
# or
$ tmux list-session
```

## 接入会话
```bash
$ tmux attach -t <session-name>
```

## 杀死会话
```bash
$ tmux kill-session -t <session-name>
```

## 切换会话
```bash
$ tmux switch -t <session-name>
```

## 重命名会话
```bash
$ tmux rename-session -t <old-name> <new-name>
```

## 会话快捷键
```
ctrl+b d：分离会话
ctrl+b s：列出所有会话
ctrl+b $：重命名当前会话
```

# 窗格操作
## 划分窗格
```bash
# 划分上下两个窗格
$ tmux split-window

# 划分左右两个窗格
$ tmux split-window -h
```

## 移动光标
```bash
# 光标切换到上方窗口
$ tmux select-pane -U

# 光标切换到下方窗格
$ tmux select-pane -D

# 光标切换到左边窗格
$ tmux select-pane -L

# 光标切换到右边窗格
$ tmux select-pane -R
```

## 交换窗格位置
```bash
# 当前窗格上移
$ tmux swap-pane -U

# 当前窗格下移
$ tmux swap-pane -D
```

## 窗格快捷键总结
```

```























