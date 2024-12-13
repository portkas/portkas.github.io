---
title: .bashrc
categories:
    - Linux
---
.bashrc是一个用于配置Bash Shell的脚本文件。位于`~/.bashrc`，当打开一个新的Bash终端会话时，Bash会自动执行这个文件中的命令，这个文件通常用于：设置环境变量，定义别名，配置Shell选项。
<!-- more-->
# 设置环境变量
## 设置PATH环境变量
```
export PATH=/usr/local/bin:$PATH
```
将/usr/local/lib目录添加到PATH环境变量的前面，当在命令行中输入命令时，系统首先会在/usr/local/lib目录先查找。

## 设置一个新的环境变量
```
export VAR = "Hello,World!"
```
创建一个名为VAR的新环境变量，并将它的值设置为`Hello,World!`

## 为特定应用设置环境变量
```
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```
设置了JAVA_HOME环境变量，指向java的安装命令，并将bin目录添加到PATH中，之后就可以直接在命令中使用java命令。

## 设置库目录
```
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```
将`/usr/local/lib`目录添加到`LD_LIBRARY_PATH`环境变量中。

## 条件性设置环境变量
```
if [ -d /opt/myapp ]; then
    export MYAPP_HOME=/opt/myapp
    export PATH=$MYAPP_HOME/bin:$PATH
fi
```
检查/opt/myapp目录是否存在，如果存在则设置MY_HOME环境变量，并将bin目录添加到PATH中。

# 设置别名
```
# 为 ls 和其他命令启用颜色支持，并添加有用的别名
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
```
`if [ -x /usr/bin/dircolors ]; `:检查 /usr/bin/dircolors 文件是否存在并且具有可执行权限，从而决定是否要执行后续命令。

`test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"`:检查 ~/.dircolors 文件是否存在并且可读。如果文件存在且可读，使用 dircolors 命令和该文件的设置来配置颜色。如果文件不存在或不可读，使用 dircolors 命令的默认设置来配置颜色。目的是确保 LS_COLORS 环境变量被设置，以便 ls 命令能够根据这些设置显示颜色。

```
# 其他别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
```