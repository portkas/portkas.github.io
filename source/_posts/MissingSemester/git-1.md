---
title: Git-1
categories:
    - Git
---
1. git核心概念

<!-- more -->

# 1. git核心概念

- 工作目录：项目目录；
- 暂存区：准备下次提交的文件列表；
- 仓库：存储项目历史记录的地方，可以是本地的，也可以是远程服务器上的；
- 本地仓库：本地电脑存储历史记录的区域；
- 远程仓库：托管在服务器上的代码副本；


# 2. 分支操作

### 基础操作

分支是用来将特性开发绝缘开来的，在其他分支上进行开发，完成后将他们合并到主分支上；

1. `git branch`：查看本地分支
2. `git branch -a`：查看所有本地和远程分支
3. `git branch <新分支名>`：创建新的分支
4. `git checkout <其他分支>`：切换分支
5. `git checkout -b <本地分支名> <远程仓库名>/<远程分支名>`：创建并切换到新的本地分支，并与远程分支建立跟踪关系
6. `git branch -d <本地分支>`：删除本地分支
7. `git push <远程仓库名> --delete <远程分支名>`：删除远程分支
8. `git branch -m <旧分支名> <新分支名>`：可以重命名本地分支，并使用 `git push origin -u <新分支名>`建立跟踪关系。
9. 切换回主分支并合并

   ```bash
   $ git checkout <主分支>
   $ git merge <子分支>
   # 对其他分支的修改不会反映到主分支上，如果想要将更改提交到主分支，则需要切换回主分支，然后合并子分支
   ```

### 替换本地改动

如果操作失误，可以使用如下命令替换掉本地改动：

```bash
$ git checkout <filename>
```

此命令会使用HEAD中的最新内容替换掉当前工作目录中的文件，已添加到暂存区的改动以及新文件不会受到影响。

![img](../../image/gitcheckout.bmp)

当我修改了一个文件，该文件还没有提交到暂存区，我想撤回修改，则可以执行该命令。

> 假如想丢弃在本地的所有改动与提交，可以到服务器上获取最新的版本历史，并将本地主分支指向它：

```bash
$ git fetch origin
$ git reset --hard origin/master
```


### 重置

当我们不想要之前提交的修改时，就会用到这个命令，比如一个错误的提交或者引入一个bug的提交，这个时候就可以使用命令：`git reset`，它可以让我们不再使用当前台面上的文件，让我们可以控制HEAD应该指向的位置。

#### 软重置

软重置会将HEAD移动至指定的提交，而不会移除该提交之后加入的修改；



#### 硬重置






# 分析-1

```bash
$ git branch
* station-computer

$ git branch -a
* station-computer
  remotes/origin/master
  remotes/origin/station-computer
  remotes/origin/zhm-old-computer
```

当前本地仓库只有一个名为 `station-computer`的分支，并且处于激活状态；

远程仓库 `origin`有三个分支：`master`，`station-computer`，`zhm-old-computer`；

### 1. 为什么 `git branch`只显示一个本地分支？

`git branch`命令默认只显示本地分支，在当前仓库中，只有一个本地分支 `station-computer`;


### 2. 如何操作其他远程分支？

#### 操作远程 `master`分支

1. 创建并切换到本地 `master`分支

   ```bash
   $ git checkout -b master origin/master
   ```

   这条命令会在本地创建一个新的 `master`分支，并将其与远程 `master`分支建立跟踪关系，然后切换到该分支。
2. 拉取远程 `master`分支的最新变更

   ```bash
   $ git push origin master
   ```

   这条命令会拉取远程 `master`分支的最新变更并合并到本地 `master`分支。

#### 操作远程 `zhm-old-computer`分支

1. 创建并切换到本地 `zhm-old-computer`分支

   ```bash
   $ git checkout -b zhm-old-computer origin/zhm-old-computer
   ```

   这条命令会在本地创建一个新的 `zhm-old-computer`分支，并将其与远程的 `zhm-old-computer`分支建立跟踪关系，然后切换到该分支。
2. 拉取远程 `zhm-old-computer`分支的最新变更

   ```bash
   $ git pull origin zhm-old-computer
   ```

   这条命令会拉取远程 `zhm-old-computer`分支的最新变更并合并到本地 `zhm-old-computer`分支。

### 3. 其他操作

- 删除远程分支
  ```bash
  $ git push origin --delete master
  $ git push origin --delete zhm-old-computer
  ```
