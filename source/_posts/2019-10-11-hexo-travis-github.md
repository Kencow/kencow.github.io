---
title: Travis CI 自动部署 Hexo 博客到 Github Pages
date: 2019-10-11 09:52:35
tags: Travis, Hexo, Github
Categories: 技术
---



最近开始在 Github Pages 上写博客，试用了几种博客框架（Hugo / Hexo / Pelican），发现在数字列表里如果有代码块的话，Hugo / Pelican 会把下一个列表数字重置为1，[解决办法](https://stackoverflow.com/questions/18088955/markdown-continue-numbered-list)是把代码块加4个空格缩进，而我是在 Mac 下用 Typora 写  Markdown 的，只有 Hexo 才能完美匹配输出的效果，所以最后选了 Hexo。



Hexo 安装好了，Github Pages 也创建好了，按照 Hexo 的官方文档还想让 Travis CI 自动部署上去。无论是 Hexo 的官方文档还是网上帖子甚至 Github 官方的某些页面，都是说让 Travis 把 master 先 build 再推送到 gh-pages 分支，再把 Github Pages 的 Source 设成 gh-pages 分支就可以了，但是现在（2019.10）完全不行。不知道 Github 什么时候把这个改了，个人主页只能用 master 分支显示，不能设置成其他分支或目录，之前用 gh-pages 分支的博客全部变成“404” :-(。



既然如此，逆向思维，让 Travis CI 逆转一下，在 repository 上从其他分支推送到 master 分支不就可以了吗？



1. 按照 Hexo 的[官方文档](https://hexo.io/zh-cn/docs/github-pages)（**步骤 1～7**），先在 Github 上建好 `<yourname>.github.io` 的 repository，用 Github 账号注册并登录 Travis CI，配置好 Travis CI 在 Github 的权限和 Token；

2. 在本地电脑上创建 Hexo 站点；

   ```bash
   hexo init my-site
   cd my-site
   npm install
   ```

3. 在 my-site 目录里新建 **.travis.yml** 文件（[参数说明](https://docs.travis-ci.com/user/deployment/pages/)），这里使用 `hexo` 作为博客的源码分支，让 Travis 自动调用 hexo 生成静态页面，最后推送到 `master` 分支；

   ```yaml
   sudo: false
   language: node_js
   node_js:
     - 10 
   cache: npm
   branches:
     only:
       - hexo # 当hexo分支有新的commit时执行 
   script:
     - hexo generate 
   deploy:
     provider: pages
     skip-cleanup: true
     local-dir: public
     target-branch: master # 注意这里是部署到master, 默认是到gh-pages
     github-token: $GH_TOKEN
     keep-history: true
     on:
       branch: hexo # 博客的源码分支
   ```

4. 在 my-site 目录里初始化本地 git，关联远程 repository，把本地 `master` 推送到远程 `hexo` 分支；

   ```bash
   git init
   git add .
   git commit -m "init hexo"
   git remote add origin https://github.com/<yourname>/<yourname>.github.io.git
   git push origin master:hexo
   ```

5. 新建一条博客，从本地的 `master` 推送到远程的 `hexo`；

   ```bash
   hexo new "hello world" # 生成在 source/_post/ 下，用你喜欢的MD编辑器吧
   git push origin master:hexo
   ```

6.  如无意外，等一会儿就能在`<yourname>.github.io`看到你新建的博客页面。可以到 Travis CI 的 Dashborad 里查看自动部署是否成功，检查 Job log。问题是 Travis 会自动 build 默认的 master 分支，而我们的 master 是没有 .travis.yml 文件的，也不需要它去 build，所以它会 failed 一次，扎眼，暂时找不到办法解决。



至此，终于又可以愉快地写 blog 了，共勉～～