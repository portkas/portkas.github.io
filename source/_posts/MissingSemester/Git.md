---
title: Git
categories:
    - Git
---
# Git
##  1.Git特点：
1.直接记录快照，而非差异比较
2.近乎所有操作都是本地执行
3.Git保证完整性
* Git中所有的数据在存储前都计算校验和，然后以校验和来引用。用以计算校验和的机制叫SHA-1哈希表，Git数据库中保存的信息都是以文件内容的哈希值来索引而不是文件名。

4.Git一般只添加数据
执行的Git操作，几乎只往Git数据库中添加数据，很难使用Git从数据库中删除数据，
<!-- more -->
## 2.Git的三种状态
* 已修改（modified）：表示修改了文件，还没保存到数据库中。
* 已暂存（staged）：表示对一个已修改文件的当前版本做了标记，使之包含在下次提交的快照中。
* 已提交（committed）：表示数据已经安全地保存在本地数据库中。

## 3.Git的三个阶段
* 工作区：是对项目的某个版本独立提取出来的内容，放在本地磁盘上供你使用和修改。
* 暂存区：它是一个文件，保存了下次将要提交的文件列表信息，一般在Git仓库目录中。
* Git仓库目录：是Git用来保存项目的元数据和对象数据库的地方。是Git中最重要的部分，从其他计算机克隆仓库时，复制的就是这部分数据。

## 4.基本的Git工作流程
1.在工作区中修改文件
2.将你想要下次提交的更改，选择性的暂存，这样只会将更改的部分添加到暂存区
3.提交更新，找到暂存区的文件，将快照永久性存储到Git目录

## 5.Git安装
Ubuntu
```Bash
$ sudo apt install get-all
```
Windows
[官网下载](https://git-scm.com/download/win)

安装完成，可以使用Git获取Git的更新：
```Git
$ git clone git://git.kernel.orgpub/scm/git/git.git
```

## 6.初次使用Git前的配置
### 配置文件
每台计算机只需要配置一次，程序升级时会保留配置信息。Git自带一个`git config`的工具来帮助设置控制Git外观和行为的配置变量。这些变量存储在三个不同的位置：
1.`/etc/gitconfig`文件：包含系统上每一个用户及他们仓库的通用配置。读写该文件中的配置变量指令为（由于他是系统配置文件，因此需要管理员或者超级用户权限来修改它）：
```bash
$ git config --system
```
2.`~/.gitconfig`或`~/.config/git/config`文件：只针对当前用户，可以传递`--global`选项让Git读写此文件，这会对系统上所有的仓库生效。
3.当前使用仓库的Git目录中的`config`文件（即`.git/config`）：针对该仓库，可以传递`--local`选项强制读写此文件。
每一个级别会覆盖上一级别的配置，即`.git/config`的配置变量会覆盖`/etc/gitconfig`中的配置变量。
可以通过以下命令查看所有的配置文件以及他们所在的文件位置：
```bash
$ git config --list --show-origin
```

### 用户信息
安装完Git之后，要做的第一件事就是设置用户名和邮箱，每一个Git提交都会使用这些信息，会写入到每次提交中。
```bash
$ git config --global user.name "example"
$ git config --global user.email example@xxx.com
```

### 文本编辑器
如果未配置，Git会使用操作系统默认的文本编辑器，如果想要使用不同的文本编辑器，例如emacs，可以运行以下命令：
```bash
$ git config --global core.editor emacs
```
在Windows系统上，如果要是用别的文本编辑器，必须指定可执行文件的完整路径。例如Nodepad++：
```bash
$ git config --global core.editor "'C:/Program Files/Nodepad++/nodepad++.exe' -miltiInst -notabbar -nosession -noPlugin"
```
* -multiInst：这个参数告诉 Notepad++ 以多实例模式运行，即每次调用都会打开一个新的 Notepad++ 窗口。
* -notabbar：这个参数隐藏标签栏，使得 Notepad++ 以单文档界面运行。
* -nosession：这个参数禁止 Notepad++ 记住上次的会话，每次打开都是一个干净的环境。
* -noPlugin：这个参数禁止 Notepad++ 加载插件，因为在某些情况下，64位版本的 Notepad++ 可能不支持所有插件。

更多编译器配置指令，在[git config core.editor](https://git-scm.com/book/zh/v2/%E9%99%84%E5%BD%95-C%3A-Git-%E5%91%BD%E4%BB%A4-%E8%AE%BE%E7%BD%AE%E4%B8%8E%E9%85%8D%E7%BD%AE#ch_core_editor)中查看具体步骤。

### 检查配置信息
```bash
$ git config --list     # 列出所有Git当时能找到的配置
$ git config user.name  # 检查Git的某一项配置
```

## 7.获取帮助
三种等价的方法获取Git命令的综合手册（manpage）：
```bash
$ git help <verb>
$ git <verb> --help
$ git git-<verb>
$ git help config   # 例如想要获得git config命令的手册
```

如果不需要全面的手册，只需要可用选项的快速参考，可以使用`-h`选项获取简明的help:
```bash
$ git add -h
```

## 8.Git基础
### 获取Git仓库
获取Git项目的两种方式：
1.将尚未进行版本控制的本地目录转换为Git仓库
2.从其他服务器克隆一个已存在的Git仓库

**在已存在目录中初始化仓库**  
linux：
```bash
$ cd my_project     # 进入该项目目录中
$ git init
```
该命令创建了一个名为.git的子目录，这个子目录中又初始化的Git仓库中所有的必须文件。但是这一步只是一个初始化操作，项目里的文件还没有被跟踪，还需要执行以下指令：
```bash
$ git add *.c
$ git add LICENSE
$ git commit -m 'initial project version'
```

**克隆现有的仓库**  
Git支持多种数据传输协议，常用的有`https://`协议和`git://`协议或者使用SSH传输协议，比如`user@server:path/to/repo.git`。以`https://`协议为例：
```bash
$ git clone https://github.com/libgit2/libgit2
```
该指令或在当前目录下创建一个名为“libgit2”的目录，并在这个目录下初始化一个.git文件夹，从远程仓库拉去下所有数据放入到.git文件夹，然后从中读取最新版本的文件的拷贝。
如果想要在克隆远程仓库的时候，自定义本地仓库的名字，可以通过以下指令：
```bash
$ git clone https://github.com/libgit2/libgit2 mylibgit
```

### 记录每次更新到仓库  
工作目录下的每个文件只有两种状态：已跟踪或未跟踪。
* 已跟踪：指那些已经被纳入版本控制的文件，在上一次的快照中有它们的记录，是git已经知道的文件。已跟踪文件又分三种状态：**未修改(unmodified)**，**已修改(modified)**，**已放入暂存区(staged)**
* 未跟踪：比如新创建的文件，还没有添加到暂存区。

**检查当前文件状态**  
```bash
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
```
1.说明现在的工作目录相当干净，所有已跟踪文件在上次提交后都未被修改过。
2.此外还表明，当前目录下没有出现任何处于未跟踪状态的新文件。
3.显示了当前所在分支，并且这个分支同远程服务器上对应的分支没有偏离。分支名是“master”，这是默认的分支名。

**把文件放入暂存区**  
```bash
$ git add .
```
`git add`命令作用：
1.可以跟踪一个新文件
Untracked files -> Changes to be committed
2.将一个被修改的已跟踪文件放入暂存区
Changes not staged for commit -> Changes to be committed
3.用于合并时把有冲突的文件标记为已解决状态
4.`git commit`提交的版本时最后一次运行`git add`命令时的那个版本。

**状态简览**  
`git status`命令输出十分详细，Git有一个选项可以缩短状态命令的输出，这样可以以简洁的方式查看更改。
```bash
$ git status -s
$ git status --short
 M README
MM Rakefile
A  lib/git.rb
M  lib/simplegit.rb
?? LICENSE.txt
```
输出有两栏（两列），左栏指明了暂存区的状态，右栏指明了工作区的状态。
* ??：表示新添加的未跟踪文件
* A：表示新添加到暂存区中的文件
* M：表示修改过的文件

例如，`README`文件在工作区已修改，但不在暂存区（暂存区那一栏为空）；`lib/simplegit.rb`文件已修改且已暂存；`Rakefile`文件已修改，暂存后又做了修改，因此该文件的修改中既有已暂存的部分，又有未暂存的部分。

**忽略文件**  
有些文件无需纳入Git的管理，也不希望总出现在未跟踪文件列表，例如日志文件，编译过程中创建的临时文件。这种情况下，可以创建一个名为`.gitignore`的文件，列出要忽略的文件的模式。例如：
```bash
$ cat .gitignore
*.[oa]
*~
```
1.第一行告诉Git忽略所有以`.o`和`.a`结尾的文件。
2.第二行告诉Git忽略所有名字以~结尾的文件。
文件`.gitignore`的格式规范如下：
* 所有空格或者以#开头的行都会被Git忽略
* 可以使用标准的glob模式（shell所使用地简化了的正则表达式）匹配，它会递归地应用在整个工作区中
* 匹配模式可以以（/）开头防止递归
* 匹配模式可以以（/）结尾指定目录
* 要忽略指定模式以外地文件或目录，可以在模式前加上叹号（！）取反

glob模式：
* 星号（ * ）匹配零个或者多个任意字符；
* [abc]匹配任何一个列在方括号中的字符，即要么匹配一个a，要么匹配一个b，要么匹配一个c；
* 问号（？）只匹配一个任意字符；
* 如果在方括号中使用短划线分割两个字符，表示所有在这两个字符范围内的都可以匹配，比如[0-9]表示匹配所有0到9的数字；
* 使用两个星号（ **  ）表示匹配任意中间目录，比如`a/ ** /z`可以匹配`a/z`,`a/b/z`,`a/b/c/z`。

```bash
# 忽略所有的 .a 文件
*.a
# 但跟踪所有的 lib.a，即便你在前面忽略了 .a 文件
!lib.a
# 只忽略当前目录下的 TODO 文件，而不忽略 subdir/TODO
/TODO
# 忽略任何目录下名为 build 的文件夹
build/
# 忽略 doc/notes.txt，但不忽略 doc/server/arch.txt
doc/*.txt
# 忽略 doc/ 目录及其所有子目录下的 .pdf 文件
doc/**/*.pdf
```

**查看已暂存和未暂存的修改**  
```bash
$ git diff
```
此命令比较工作目录中当前文件和暂存区快照之间的差异，也就是修改之后还没有暂存起来的变化内容。`git diff`查看的是尚未暂存的文件更新了哪些内容。如果先执行`git add`指令，再运行`git diff`会发现什么也没有。

```bash
$ git diff --staged
diff --git a/README b/README
new file mode 100644
index 0000000..03902a1
--- /dev/null
+++ b/README
@@ -0,0 +1 @@
+My Project
```
此命令查看已暂存的将要添加到下次提交里的内容。这条命令将对比已暂存文件与最后一次提交的文件差异。

**提交更新**  
```bash
$ git commit
```
将暂存区的文件进行提交，在提交之前需要确认还有什么已修改或新建的文件还没有`git add`过，否则提交的时候不会记录这些尚未暂存的变化。所以每次提交之前，先用`git status`查看，所需要的文件是不是都已经暂存起来了，然后再进行提交。

默认的提交消息包含最后一次运行`git status`的输出，放在注释行里。更详细的内容修改提示可以使用`git commit -v`这会使所作的更改的diff输出呈现在编辑器中，以便让你知道本次提交具体做出了哪些修改。

```bash
$ git commit -m "explanatory note"
[master 463dc4f] Story 182: Fix benchmarks for speed
 2 files changed, 2 insertions(+)
 create mode 100644 README
```
这样就完成了一次提交，上面会显示，当前在哪个分支（master）提交的，本次提交的完整的SHA-1校验和是什么（463dc4f），以及在本次提交中有多少文件修订过，多少行添加和删改过。

**跳过使用暂存区域**  
```bash
$ git commit -a -m "explanatory note"
[master 83e38c7] added new benchmarks
 1 file changed, 5 insertions(+), 0 deletions(-)
```
该命令会自动把已经跟踪过的文件暂存起来一并提交，从而跳过`git add`步骤。

**移除文件**  
要从Git中移除某个文件，就必须要从已跟踪文件清单中移除（即从暂存区移除）然后提交。可以使用命令`git rm`
如果只是简单的从工作目录中手动删除文件，运行`git status`可以看到在“Changes not staged for commit” 部分（也就是 未暂存清单）有：
```bash
$ rm PROJECTS.md
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        deleted:    PROJECTS.md

no changes added to commit (use "git add" and/or "git commit -a")
```
然后再运行`git rm`记录此次移除文件的操作：
```bash
$ git rm PROJECTS.md
rm 'PROJECTS.md'
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    deleted:    PROJECTS.md
```
下一次提交时，该文件就不再纳入版本管理了。
```bash
# 如果要删除之前已经修改或已经放到暂存区的文件，则必须使用强制删除`-f`选项
$ git rm -f <files>

# 如果想把文件从Git仓库中移除（即从暂存区移除），但仍希望保留在当前工作目录中。即想让文件保留在磁盘中，但是不想让Git继续跟踪。比如当忘记添加.gitignore文件，不小心把一大堆.a文件添加到暂存区时
$ git rm --cached README

# git rm命令后面可以列出文件或者目录的名字，也可以使用glob模式，比如删除`log/`目录下扩展名为`.log`的所有文件（星号之前的反斜杠，因为Git有它自己的文件模式扩展匹配，所以我们不用shell来帮忙展开）：
$ git rm log/\*.log

# 删除所有以名字以~结尾的文件
$ git rm \*~
```

**移动文件**  
重命名文件操作：`git mv`
```bash
$ git mv README.md README
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    renamed:    README.md -> README
```
该命令将README.md重命名为README。其实，运行`git mv`就相当于运行了下面三条命令：
```bash
$ mv README.md README
$ git rm README.md
$ git add README
```

### 查看提交历史
```bash
# 查看提交历史
$ git log
commit ca82a6dff817ec66f44342007202690a93763949
Author: Scott Chacon <schacon@gee-mail.com>
Date:   Mon Mar 17 21:52:11 2008 -0700

    changed the version number

commit 085bb3bcb608e1e8451d4b2432f8ecbe6306e7e7
Author: Scott Chacon <schacon@gee-mail.com>
Date:   Sat Mar 15 16:40:33 2008 -0700

    removed unnecessary test

commit a11bef06a3f659402fe7563abf99ad00de2209e6
Author: Scott Chacon <schacon@gee-mail.com>
Date:   Sat Mar 15 10:31:28 2008 -0700

    first commit
```
不传入任何参数的默认情况下，`git log`会按时间先后顺序列出所有的提交，最近的排在最上面。这个命令会列出每个提交的校验和，作者的名字和电子邮件地址，提交时间，提交说明。
```bash
$ git log -p -2
```
这个命令会显示每次提交所引入的差异，`-2`选项限制只显示最近的两次提交。
```bash
$ git log --stat
```
这个选项可以看到每次提交的简略统计信息。当进行代码审查，或者快速浏览某个搭档的提交所带来的变化的时候，可以使用这个参数。`--stat`选项在每次提交的下面列出所有被修改过的文件，有多少文件被修改了以及被修改过的文件的哪些行被移除或被添加。
```bash
$ git log --pretty=oneline
ca82a6dff817ec66f44342007202690a93763949 changed the version number
085bb3bcb608e1e8451d4b2432f8ecbe6306e7e7 removed unnecessary test
a11bef06a3f659402fe7563abf99ad00de2209e6 first commit
```
`--pretty`这个选项可以使用不同于默认格式的方式展示提交历史。`oneline`会将每个提交放在一行显示。
```bash
$ git log --pretty=format:"%h - %an, %ar : %s"
ca82a6d - Scott Chacon, 6 years ago : changed the version number
085bb3b - Scott Chacon, 6 years ago : removed unnecessary test
a11bef0 - Scott Chacon, 6 years ago : first commit
```
`format`选项可以定制记录的显示格式，还有[其他常用选项](https://git-scm.com/book/zh/v2/Git-%E5%9F%BA%E7%A1%80-%E6%9F%A5%E7%9C%8B%E6%8F%90%E4%BA%A4%E5%8E%86%E5%8F%B2#pretty_format)列出了`format`接受的常用格式占位符的写法及其代表的意义。
`git log`常用选项：
* -p：按补丁格式显示每个提交引入的差异
* --stat：显示每次提交的文件修改统计信息
* --shortstat：只显示--stat中最后的行数修改添加移除统计
* --name-status：显示新增，修改，删除的文件清单
* --abbrev-commit：仅显示校验和所有40个字符的前几个字符
* --relative-date：使用较短的相对时间而不是完整格式显示日期（比如：“2 weeks ago”）
* --graph：在日志旁以ASCII图形显示分支与合并历史
* --pretty：使用其他格式显示历史提交信息。可用的选项包括oneline,short,full,fuller,format
* --oneline：--pretty=oneline --abbrev-commit合并的简写

**限制输出长度**  
限制`git log`[输出的常用选项](https://git-scm.com/book/zh/v2/Git-%E5%9F%BA%E7%A1%80-%E6%9F%A5%E7%9C%8B%E6%8F%90%E4%BA%A4%E5%8E%86%E5%8F%B2#limit_options):
* -<n>：仅显示最近的n条提交
* --since，after：仅显示指定时间之后的提交
* --until，--before：仅显示指定事件之前的提交
* --author：仅显示作者匹配指定字符串的提交
* --committer：今昔那是提交者匹配指定字符串的提交
* --grep：仅显示提交说明中包含指定字符串的提交
* -S：仅显示添加或者删除内容匹配指定字符串的提交

```bash
$ git log --pretty="%h - %s" --author='Junio C Hamano' --since="2008-10-01" \
   --before="2008-11-01" --no-merges -- t/
5610e3b - Fix testcase failure when extended attributes are in use
acd3b9e - Enhance hold_lock_file_for_{update,append}() API
f563754 - demonstrate breakage of detached checkout with symbolic link HEAD
d1a43f2 - reset --hard/read-tree --reset -u: remove unmerged new paths
51a94af - Fix "checkout --track -b newbranch" on detached HEAD
b0ad11e - pull: allow "git pull origin $something:$current_branch" into an unborn branch
```
使用以上命令在Git源码库中查看Junio Hamano在2008年10月期间，除了合并提交之外的哪一个提交修改了测试文件。

### 撤销操作
**修补提交**  
```bash
$ git commit -m 'initial commit'
$ git add forgotten_file
$ git commit --amend
```
`git commit --amend`修补提交命令会将暂存区中的文件提交，如果字上次提交以来暂存区还未做任何修改，那么快照会保持不变，如果暂存区有修改或者变化，那么执行该指令会将覆盖上一次提交。ps.修补提交最明显的价值是可以稍微改进你最后的提交，而不会让“啊，忘了添加一个文件”或者 “小修补，修正笔误”这种提交信息弄乱你的仓库历史。

**取消暂存的文件**  
当已经修改了两个文件并且想要将它们作为两次独立的修改提交，但是却意外地输入"git add *"暂存了它们两个，如何只取消暂存两个中的一个呢？
```bash
$ git reset HEAD README.md
```
通过该命令取消暂存"README.md"文件。

**撤销对文件的修改**  
撤销修改即把文件还原成上次提交时的样子：
```bash
$ git checkout README.md
```

### 远程仓库的使用
**查看远程仓库**  
`git remote`命令：列出指定的每一个远程服务器的简写。origin——这是Git给你克隆的仓库服务器的默认名字。
```bash
$ git clone https://github.com/schacon/ticgit
Cloning into 'ticgit'...
remote: Reusing existing pack: 1857, done.
remote: Total 1857 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (1857/1857), 374.35 KiB | 268.00 KiB/s, done.
Resolving deltas: 100% (772/772), done.
Checking connectivity... done.
$ cd ticgit
$ git remote
origin
```
也可以指定选项`-v`，用于显示当前Git仓库中配置的所有远程仓库的详细信息，包括他们的URL以及对应的远程仓库的简称。
```bash
$ git remote -v
origin	https://github.com/schacon/ticgit (fetch)
origin	https://github.com/schacon/ticgit (push)
```

**添加远程仓库**  
`git remote add <shortname> <url>`添加一个新的远程Git仓库，同时指定一个方便使用的简写。
```bash
$ git remote
origin
$ git remote add pb https://github.com/paulboone/ticgit
$ git remote -v
origin	https://github.com/schacon/ticgit (fetch)
origin	https://github.com/schacon/ticgit (push)
pb	https://github.com/paulboone/ticgit (fetch)
pb	https://github.com/paulboone/ticgit (push)
```
之后可以在命令行中使用字符串pb来替代整个URL。例如想要拉取Paul的仓库中有但你没有的信息，可以运行`git fetch pb`:
```bash
$ git fetch pb
remote: Counting objects: 43, done.
remote: Compressing objects: 100% (36/36), done.
remote: Total 43 (delta 10), reused 31 (delta 5)
Unpacking objects: 100% (43/43), done.
From https://github.com/paulboone/ticgit
 * [new branch]      master     -> pb/master
 * [new branch]      ticgit     -> pb/ticgit
```

**从远程仓库中抓取和拉取**  
```bash
$ git fetch <remote>
```
该命令会访问远程仓库，从中拉去所有你还没有的数据。执行完之后，你将拥有那个远程仓库中所有分支的引用，可以随时合并或者查看。`git fetch`命令只会讲数据下载到本地仓库，并不会自动合并或修改当前的工作，必须手动将其合并到你的工作。
如果当前分支设置了跟踪远程分支，那么可以用`git pull`命令自动抓取后合并该远程分支到当前分支。
默认情况下，`git clone`命令会自动设置本地master分支跟踪远程仓库的master分支（或其他名字的默认分支）。
运行`git pull`通常会从最初克隆的服务器上抓取数据并自动尝试合并到当前所在的分支。

**推送到远程仓库**  
```bash
$ git push origin master
```
该命令讲master分支推送到origin服务器（克隆时通常会自动帮你设置好那两个名字）。执行该命令可以将你做的工作备份到服务器。
只有当你有所克隆服务器的写入权限，并且之前没有人推送过时，这条命令才会生效。当你和其他人在同一时间克隆，它们先推送到上游，然后你再推送到上游，你的推送就会被拒绝。必须先抓取他们地工作，并将其合并进你的工作后才能推送。

**查看某个远程仓库**  
```bash
$ git remote show origin
* remote origin
  Fetch URL: https://github.com/schacon/ticgit
  Push  URL: https://github.com/schacon/ticgit
  HEAD branch: master
  Remote branches:
    master                               tracked
    dev-branch                           tracked
  Local branch configured for 'git pull':
    master merges with remote master
  Local ref configured for 'git push':
    master pushes to master (up to date)
```
运行该命令，会列出远程仓库地URL与跟踪分支的信息。他告诉你正处于master分支，并且如果运行`git pull`就会抓取所有的远程引用，然后将远程master分支合并到本地master分支。它也列出了抓取到的所有远程引用。

**远程仓库的重命名与移除**  
```bash
# 远程仓库的重命名 
$ git remote rename <beforename> <aftername>

# 远程仓库的移除
$ git remote remove <name>
```

### 打标签
Git可以给仓库历史中的某个提交打上标签，以示重要。
**列出标签**  
```bash
# 列出已有的标签
$ git tag

# 按照特定的模式查找标签
$ git tag -l "v1.8.5*"
```

**创建标签：附件标签**
附件标签是一个存储在Git数据库中的一个完整对象，是可以被校验的，其中包含打标签者的名字，电子邮件地址，日期以及标签信息。
```bash
$ git tag -a v1.4 -m "explanatory note"
$ git tag
v1.4
```
可以使用`git show`命令看到标签信息和与之对应的提交信息

**创建标签：轻量标签**  
轻量标签本质上是将提交校验和存储到一个文件中，没有保存任何其他信息。
```bash
$ git tag v1.4-lw
```

**后期打标签**  
假设在v1.2时忘记给项目打标签，可以在之后补上标签，要在哪个提交上打标签，就需要在命令的末尾指定提交的校验和（或者部分校验和）
```bash
$ git tag -a v1.2 9fceb02
```

**共享标签**  
默认情况下，`git push`命令并不传送标签到远程服务器上，在创建完标签后必须显式地推送标签到共享服务器上。
```bash
$ git push origin v1.4
```
如果想一次性推送很多标签，也可以使用`--tags`选项，它可以将所有不在远程仓库上服务器上的标签全部传送到那里。
```bash
$ git push origin --tags
```

**删除标签**  
```bash
# 第一种方法
$ git tag -d v1.4-lw    # 删除本地仓库上的标签
$ git push origin :refs/tags/v1.4-lw # 更新远程仓库，将冒号前面的空置推到远程标签名，从而删除远程仓库中的标签

# 第二种方法
$ git push origin --delete <tagname>
```

### Git别名
可以通过`git config`文件给命令设置别名（Git只是简单的将别名替换为对应的命令）
```bash
# 给checkout起个别名co
$ git config --global alias.co checkout

# 给reset HEAD --起个别名unsatge
$ git config --global alias.unstage 'reset HEAD --'
```

## 9.Git分支
### 分支简介
使用分支，可以把你的工作从主线上分离开来，以免影响开发主线。Git的分支而不能之上仅仅是指向提交对象的可变指针。
**分支创建**  
```bash
$ git branch testing
```
创建了一个testing分支。本质上是创建了一个可以移动的新指针。但是仍然在master分支上，因为`git branch`命令仅仅创建一个新分支，并不会自动切换到新分支中去。Git通过HEAD的特殊指针，从而知道当前所在的本地分支是哪一个。如果想要创建一个新分支后立即切换过去，可以使用：
```bash
$ git chechout -b <newbranchname>
```
![两个指向相同提交历史的分支](https://git-scm.com/book/en/v2/images/head-to-master.png)  
```bash
$ git log --oneline --decorate
f30ab (HEAD -> master, testing) add feature #32 - ability to add new formats to the central interface
34ac2 Fixed bug #1328 - stack overflow under certain conditions
98ca9 The initial commit of my project
```
可以使用该命令查看各个分支当前所指的对象。本示例中，当前master和testing分支均指向校验和以f30ab开头的提交对象。

**分支切换**  
要切换到一个已存在的分支，使用`git chechout`命令，示例：切换到新创建的testing分支
```bash
$ git chechout testing
```
这样，HEAD就指向testing分支了。后面我们再进行一次提交：
```bash
$ vim test.rb
$ git commit -a -m  "made a change"
```
![HEAD分支随着提交操作自动向前移动](https://git-scm.com/book/en/v2/images/advance-testing.png)  
可以看到，testing分支向前移动，但是master分支并没有。当切换回master分支时：
```bash
$ git chechout master
```
![](https://git-scm.com/book/en/v2/images/checkout-master.png)  
这条命令做了两件事，一是使HEAD指向master分支，二是将目录工作恢复成master分支所指向的快照内容。本质上来讲，就是忽略testing分支所作的修改，以便于向另一个方向进行开发。
此时，再做些修改并提交：
```bash
$ vim test.rb
$ git chechout -a -m "made other changes"
```
![](https://git-scm.com/book/en/v2/images/advance-master.png)  
可以看到，这个项目的提交历史产生了分叉。可以简单的使用`git log`命令查看分叉历史。
```bash
# 输出提交历史，各个分支的指向以及项目的分支分叉情况
$ git log --oneline --decorate --graph --all
* c2b9e (HEAD, master) made other changes
| * 87ab2 (testing) made a change
|/
* f30ab add feature #32 - ability to add new formats to the
* 34ac2 fixed bug #1328 - stack overflow under certain conditions
* 98ca9 initial commit of my project
```

### 分支的创建与合并
简单的分支新建和分支合并的工作流：  
   1.开发某个网站。
   2.为实现某个新的用户需求，创建一个分支。
   3.在这个分支上开展工作。
正在此时，你突然接到一个电话说有个很严重的问题需要紧急修补。 你将按照如下方式来处理：  
   1.切换到你的线上分支（production branch）。
   2.为这个紧急任务新建一个分支，并在其中修复它。
   3.在测试通过之后，切换回线上分支，然后合并这个修补分支，最后将改动推送到线上分支。
   4.切换回你最初工作的分支上，继续工作。

#### 新建分支
1.解决公司的新需求#52问题，于是创建一个分支并同时切换到那个分支上
```bash
# 方法一
$ git chechout -b iss52 # 创建并切换分支

#方法二
$ git branch iss52      # 创建分支
$ git chechout iss52    # 切换分支
```
![](https://git-scm.com/book/en/v2/images/basic-branching-2.png)  

2.在#53问题上工作，并且做了一些提交。在此过程中iss52分支不断地向前推进。
```bash
$ vim index.html
$ git commit -a -m "added a new footer[issue 53]"
```
![](https://git-scm.com/book/en/v2/images/basic-branching-3.png)  

3.接到电话有个很严重的问题需要紧急修补。于是要切换到线上分支，并为这个紧急任务新建一个hotfix分支，在该分支上工作直到问题解决
```bash
$ git checkout master
Switched to branch 'master'
$ git checkout -b hotfix
Switched to a new branch 'hotfix'
$ vim index.html
$ git commit -a -m 'fixed the broken email address'
[hotfix 1fb7853] fixed the broken email address
 1 file changed, 2 insertions(+)
```
![](https://git-scm.com/book/en/v2/images/basic-branching-4.png)  

4.运行你的测试，确保修改是正确的，然后将hotfix分支合并回master分支来部署到线上。
```bash
$ git checkout master
$ git merge hotfix
Updating f42c576..3a0874c
Fast-forward
 index.html | 2 ++
 1 file changed, 2 insertions(+)
```
![](https://git-scm.com/book/en/v2/images/basic-branching-5.png)  

5.这个紧急问题地解决方案发布以后，你准备回到被打断之前地工作中。在此之前，先删除hotfix分支，因为已经不再需要他了，master分支已经指向同一个位置。
```bash
$ git branch -f hotfix
Deleted branch hotfix (3a0874c).
$ git chechout iss53
Switched to branch "iss53"
$ vim index.html
$ git commit -a -m 'finished the new footer [issue 53]'
[iss53 ad82d7a] finished the new footer [issue 53]
1 file changed, 1 insertion(+)
```
![](https://git-scm.com/book/en/v2/images/basic-branching-6.png)  

#### 分支的合并：解决冲突
6.当完成#53问题的需求后，打算将工作合并入master分支。为此需要合并iss53分支到master分支。合并之后就不需要iss53分支了，可以在最后删除这个分支。
```bash
$ git checkout master
Switched to branch 'master'
$ git merge iss53
Merge made by the 'recursive' strategy.
index.html |    1 +
1 file changed, 1 insertion(+)
$ git branch -d iss53
```
![](https://git-scm.com/book/en/v2/images/basic-merging-2.png)  

7.遇到冲突时的分支合并
如果你对#53问题的修改和有关hotfix分支的修改都涉及到同一个文件的同一处，在合并他们的时候就会产生合并冲突：
```bash
$ git merge iss53
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```
此时Git做了合并，但是没有自动地创建一个新的合并提交，Git回暂停下来，等待你去解决合并产生地冲突。在合并冲突之后可以使用`git status`命令查看那些因为包含合并冲突而处于未合并状态的文件。

任何因包含合并冲突而有待解决的文件，都会以未合并状态标识出来。Git会在有冲突的文件中加入标准的冲突解决标记：
```
<<<<<<< HEAD:index.html
<div id="footer">contact : email.support@github.com</div>
=======
<div id="footer">
 please contact us at support@github.com
</div>
>>>>>>> iss53:index.html
```
这表示HEAD所指示的版本（也就是你的master分支所在的位置）在这个区段的上半部分（ === 的上半部分），iss53分支所示的版本在 === 的下半部分。为了解决冲突，必须选择由===分割的两个部分中的一个，或者自行合并这些内容，例如，可以通过把这段内容换成下面的样子来解决冲突：
```
<div id="footer">
please contact us at email.support@github.com
</div>
```
上述的冲突解决方案仅保留了其中一个分支的修改，并且`<<==>>`这些行被完全删除。在解决了所有文件里的冲突之后，对每个文件使用`git add` 命令来将其标记为冲突已解决。一旦暂存了这些原本有冲突的文件，Git就会将他们标记为冲突已解决，

图像化工具：`git mergetool`会启动一个可视化的合并工具，并带着你一步一步解决这些冲突。

### 分支管理
```bash
$ git branch
  iss53
* master
  testing
```
`git branch`命令不仅可以创建和删除分支，如果不加任何参数，该命令表示列出当前所有分支。master分支前面的 * 表示现在检出的那一个分支（也就是HEAD指针所指向的分支）。如果想要查看每一个分支的最后一次提交可以运行`git branch -v`命令。

`--merged`和`--no-merged`选项可以过滤这个列表中已经合并或尚未合并到当前分支的分支。
```bash
# 查看哪些分支已经合并到当前分支
$ git branch --merged

# 查看所有包含未合并工作的分支
$ git branch --no-merged
```

对于未合并的分支，尝试使用`git branch -d`命令会失败，因为它包含了还未合并的工作，如果真的想要删除分支并丢掉那部分工作，可以使用`-D`强制删除。

### 分支开发工作流
#### 长期分支
只在master分支上保留完全稳定的代码，还有一些名为develop
或topic的平行分支，用在做后续开发或者测试稳定性，这些分支不必保持绝对稳定，一旦达到稳定状态，就可以合并入master分支。
![](https://git-scm.com/book/en/v2/images/lr-branches-2.png)  

#### 主题分支
主题分支是一种短期分支，被用来实现单一特性或其相关工作。比如上文中用到主题分支（iss53和hotfix分支）提交了一些更新，并在他们合并入主干分支之后，又删除了他们。
考虑这样一个例子，你在 master 分支上工作到 C1，这时为了解决一个问题而新建 iss91 分支，在 iss91 分支上工作到 C4，然而对于那个问题你又有了新的想法，于是你再新建一个 iss91v2 分支试图用另一种方法解决那个问题，接着你回到 master 分支工作了一会儿，你又冒出了一个不太确定的想法，你便在 C10 的时候新建一个 dumbidea 分支，并在上面做些实验。 你的提交历史看起来像下面这个样子：
![](https://git-scm.com/book/en/v2/images/topic-branches-1.png)  
现在，我们假设两件事情：你决定使用第二个方案来解决那个问题，即使用在 iss91v2 分支中方案。 另外，你将 dumbidea 分支拿给你的同事看过之后，结果发现这是个惊人之举。 这时你可以抛弃 iss91 分支（即丢弃 C5 和 C6 提交），然后把另外两个分支合并入主干分支。 最终你的提交历史看起来像下面这个样子：
![](https://git-scm.com/book/en/v2/images/topic-branches-2.png)  

### 远程分支
可以通过`git ls-remote <remote>`来显示地获得远程引用地完整列表，或者通过`git remote show <remote>`获得远程分支地更多信息。
```bash
$ git remote -v
origin  git@github.com:portkas/portkas.github.io.git (fetch)
origin  git@github.com:portkas/portkas.github.io.git (push)

$ git ls-remote origin
33e33baaadb70a791936b45c4f7a47ca104cdc1a        HEAD
33e33baaadb70a791936b45c4f7a47ca104cdc1a        refs/heads/hexo
294c8b3fa958a2f46defa546b0e137a91f0927d9        refs/heads/master
```
远程分支只是分支的一种。本地的主分支为master，远程的主分支为origin/master，这是两个不同的分支。
![](https://git-scm.com/book/en/v2/images/remote-branches-1.png)  
如果你在本地master分支做了一些工作，在同一时间内其他人推送提交到 `git.ourcomoany.com`并且更新了他的master分支，也就是说你们的提交历史走向不同的方向。即便如此，只要保持不与origin服务器连接并拉取数据，你的origin/master指针就不会移动。
![](https://git-scm.com/book/en/v2/images/remote-branches-2.png)  
如果要与给定的远程仓库同步数据，运行`git fetch <remote>`命令（在本例中为`git fetch origin`）。这个命令会查找origin是哪一个服务器（在本例中是`git.ourcompany.com`），从中抓取本地没有的数据，并且更新本地数据库，移动origin/master指针到更新之后的位置。
![](https://git-scm.com/book/en/v2/images/remote-branches-3.png)  

#### 推送
本地地分支并不会自动与远程分支同步，必须显式地推送想要 分享的分支。可以把不愿意分享的内容放到私人分支上，而将需要和别人协作的内容推送到公开分支。
如果希望和别人一起在名为serverfix的分支上工作，运行`git push <remote> <branch>`:
```bash
$ git push origin serverfix
Counting objects: 24, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (15/15), done.
Writing objects: 100% (24/24), 1.91 KiB | 0 bytes/s, done.
Total 24 (delta 2), reused 0 (delta 0)
To https://github.com/schacon/simplegit
 * [new branch]      serverfix -> serverfix
```

下一次其他协作者从服务器上抓取数据时，他们会在本地生成一个远程分支origin/serverfix，指向服务器的serverfix分支的引用。
需要特别注意的是，当抓取到新的远程跟踪分支时，本地不会自动生成一份可编辑的副本，即本地不会有一个新的serverfix分支，只有一个不可修改的origin/serverfix指针。
可以运行`git merge origin/serverfix`将这些工作合并到当前所在的分支。如果想要在serverfix分支上工作，可以将其建立在远程跟踪分支之上：
```bash
$ git checkout -b serverfix origin/serverfix
Branch serverfix set up to track remote branch serverfix from origin.
Switched to a new branch 'serverfix'
```
这会给你一个用于工作的本地分支，并且起点位于origin/serverfix。

#### 跟踪分支
当克隆一个仓库时，通常会自动地设置一个跟踪origin/master地master分支。如果在一个跟踪分支上输入`git pull`，Git能自动地识别去哪个服务器上抓取，合并到哪个分支。
也可以设置其他地跟踪分支，运行`git checkout -b <branch> <remote>/<branch>`，这是一个常用地操作，所以Git提供了--track快捷方式：
```bash
$ git checkout --track origin/serverfix
Branch serverfix set up to track remote branch serverfix from origin.
Switched to a new branch 'serverfix'
```
由于该操作太常用了，该快捷方式还有一个快捷方式：
```bash
$ git checkout serverfix
Branch serverfix set up to track remote branch serverfix from origin.
Switched to a new branch 'serverfix'
```
如果想要将本地分支与远程分支设置为不同的名字，可以使用命令：
```bash
$ git checkout -b sf origin/erverfix
Branch sf set up to track remote branch serverfix from origin.
Switched to a new branch 'sf'
```
现在，本地分支sf会自动从origin/serverfix拉取。

如果想要修改正在跟踪地上有分支（即和本地分支绑定地服务器分支），可以在任意时间使用`-u`或`--set-upstream-to`选项来运行`git branch`来显示地设置：
```bash
# 首先要先有一个本地分支，然后切换到这个分支，然后运行该指令指定要跟踪地远程分支
$ git branch -u origin/serverfix
Branch serverfix set up to track remote branch serverfix from origin.
```
如果要查看设置地所有跟踪分支，可以使用`git branch -vv`，会将所有地本地分支列出来，并且包含更多的信息，比如每一个分支正在跟踪哪个远程分支，本地分支是领先还是落后。
```bash
$ git branch -vv
  iss53     7e424c3 [origin/iss53: ahead 2] forgot the brackets
  master    1ae2a45 [origin/master] deploying index fix
* serverfix f8674d9 [teamone/server-fix-good: ahead 3, behind 1] this should do it
  testing   5ea463a trying something new
```
可以看到iss53分支正在跟踪origin/iss53并且ahead是2，意味着本地有两个提交还没有推送到服务器。master分支正在跟踪origin/master分支并且是最新的。serverfix分支正在跟踪teamone服务器上的server-fix-good分支并且领先3落后1，意味着服务器上有一次还没有合并，同时本地还有三次提交没有推送。
需要注意的是，这些数字的值来自于你从服务器上最后一次抓取的数据，这个命令没有连接服务器，所以只会告诉你本地缓存的服务器数据，如果想要统计最新的领先和落后数字，可以在统计前抓取所有的远程仓库：
```bash
$ git fetch --all
$ git branch -vv
```


#### 拉取
`git fetch`命令从服务器上抓取本地没有的数据时，它并不会修改工作目录中的内容，它只会获取数据然后让你自己合并。
`git pull`命令在大多数情况下含义是一个`git fetch`紧接着一个`git merge`命令。该指令会查找当前分支所跟踪的服务器与分支，从服务器上抓取数据然后尝试合并入那个远程分支。
由于`git pull`经常令人困惑，通常单独显式地使用`git fetch`与`git merge`

#### 删除远程分支
当已经通过远程分支做完所有的工作后，可以运行`git push --delete <branch>`命令删除一个远程分支，例如要从服务器上删除serverfix分支：
```bash
$ git push origin --delete serverfix
To https://github.com/schacon/simplegit
 - [deleted]         serverfix
```