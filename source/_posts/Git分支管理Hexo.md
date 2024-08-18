---
title: Git分支管理Hexo
---
# 1.本地初始电脑
1.初始化Git仓库
```bash
$ cd blog
$ git init  # 创建.git子目录
```

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

2.拉取远端仓库
```bash
$ git clone git@github.com:yourname/yourname.github.io.git blogname
```

3.安装Hexo
```bash
$ npm install -g hexo-cli
```

4.安装`deploy-git`
```bash
$ npm install hexo-deployer-git --save
```

5.在`./source/_post/`中添加.md博客并生成
```bash
$ hexo clean
$ hexo g
$ hexo d
```

6.将本地仓库推送至远端
```bash
$ git push origin master
```