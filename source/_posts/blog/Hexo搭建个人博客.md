---
title: Hexo搭建个人博客
categories:
    - 个人博客
---
# 1.前置条件
* [Node.js](https://nodejs.org/en/download/package-manager/current)
* [git](https://git-scm.com/)
* Github Pages
<!-- more -->
# 2.安装Node.js
```bash
# installs nvm (Node Version Manager)
$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# download and install Node.js (you may need to restart the terminal)
$ nvm install 22

# verifies the right Node.js version is in the environment
$ node -v # should print `v22.6.0`

# verifies the right npm version is in the environment
$ npm -v # should print `10.8.2`
```

# 3.本地运行Hexo
## 安装Hexo
```bash
$ mkdir blog
$ cd blog
$ npm install -g hexo-cli   # 安装hexo
$ hexo init                 # 初始化hexo
$ hexo install              # 安装需要的包
```
初始化完成后项目文件夹如下所示：
.
├── _config.yml     
├── package.json    
├── scaffolds       
├── source          
|   ├── _drafts     
|   └── _posts      
└── themes          

## Hexo的用法
* 启动内置预览服务（默认端口4000）
    ```bash
    $ hexo s    # hexo serve
    ```
* 生成网站
    ```bash
    $ hexo g    # hexo generate
    ```
* 部署到Github Pages上（部署之前需要配置）
    ```bash
    $ hexo d    # hexo deploy
    
    # 生成并部署，省去hexo g
    $ hexo d -g
    ```
* #清除缓存文件db.json和已生成的静态文件 public
    ```bash
    $ hexo c    # hexo clean
    ```
* 创建博客
    ```bash
    # 创建完成后博客的.md文件存储在`./source/_post/`中
    $ hexo new "blog name"
    ```

# 3.配置
_config.yml
* title : 网站标题
* subtitle : 副标题
* description : 网站描述
* keywords : 网站关键词
* author : 作者
* language : 语言
* timezone : 时区

以上设置会出现在meta里。
* url : 网址
* root : 网站根目录
* permalink : 永久链接格式，比如year/:month/:day/:title/
* source_dir : 源文件夹，默认source
* public_dir : 生成的网站文件夹
* theme : 主题

官网关于配置的描述：https://hexo.io/zh-cn/docs/configuration

# 4.部署到Github Pages
0.配置github的SSH
1.创建repo:git@github:yourname/yourname.github.io.git
2.修改配置文件`_config.yml`
```
deploy:
  type: git
  repo: git@github.com:yourname/yourname.github.io.git
  branch: main
```
4.安装`deploy-git`
```bash
$ npm  install hexo-deployer-git --save
```

# Reference
* [Hexo官网](https://hexo.io/docs/)
* [从零搭建 Hexo + Github 博客](https://www.luogu.com.cn/article/vglpq15p)
* [Hexo 使用记录](https://note.tonycrane.cc/cs/tools/hexo/)
* [Hexo写作](https://hexo.io/zh-cn/docs/writing)
* [主题](https://github.com/ppoffice/hexo-theme-icarus)
