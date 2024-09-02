---
title: Git分支管理Hexo
categories:
    - 个人博客
---
# 1.本地初始电脑
1.初始化Git仓库
```bash
$ cd blog
$ git init  # 创建.git子目录
```
<!-- more -->
2.添加远程仓库
```bash
$ git remote add origin git@github.com:yourname/yourname.github.io.git
```

3.拉取远端仓库所有内容及分支
```bash
$ git fetch origin
```

5.新建分支
```bash
$ git checkout -b master
```

4.在`./source/_post/`中添加.md博客并生成
```bash
$ hexo clean
$ hexo g
$ hexo d
```

5.将本地仓库推送至远端
```bash
$ git push origin master
```

# 2.其他电脑
1.安装Node.js

2.拉取远端仓库并进入文件夹
```bash
$ git clone git@github.com:yourname/yourname.github.io.git blogname
$ cd blogname
```

3.拉取远端仓库分支并切换至master分支（默认分支是main，master分支是自己建的）
```bash
$ git fetch origin
$ git checkout master
```

4.安装Hexo及相关依赖
```bash
$ npm install hexo	# 安装hexo
$ npm install hexo-cli -g # 重新安装(如果上述安装不起作用）
$ npm install	# 安装依赖
```

5.安装`deploy-git`
```bash
$ npm install hexo-deployer-git --save
```

6.在`./source/_post/`中添加.md博客并生成
```bash
$ hexo clean
$ hexo g
$ hexo d
```

8.将本地仓库推送至远端
```bash
$ git push origin master
```

# 3.更换主题
1.进入`./themes`文件夹

2.github上clone喜欢的主题
```bash
$ git clone git@github.com:xxx/xxx.git file-name
```

3.进入`file-name`文件夹

4.删除.git文件夹
```bash
$ rm -r .git
```

5.修改最外层目录下的`_config.yml`文件
theme: file-name

6.修改.gitignore文件（或者把里面内容删掉也行）

7.将本地仓库推送至远端
```
$ git add .
$ git commit -m "add theme"
$ git push origin master
```

ps.修改好主题之后，主题配置在`file-name`文件夹中的`_config.yml`中进行配置。


# 4.说明
`main`分支用来部署博客：当执行`hexo d`的时候，博客部署在`main`分支，不需要执行`git push origin main`，因为`hexo d`指令已经将相应的`html`文件推送到远端服务器的`main`分支上了。
`master`分支用来存储文件：比如`.md`文件，存放在`./source/_post`文件夹中，最后需要手动执行`git push origin master`。
