
## 1. pull_codereview_branches.sh
>做Codereview时，经常需要把代码分支和它对应的主干拉到本地，然后使用文件比较工具，比如Mac下的DiffMerge来做代码变更对比，手工拉取非常不便，写了脚本来自动实现。唯一麻烦就是需要把分支拷贝到一个文件，然后才能执行shell命令。

自动从指定的文件中解析branches和它对应的主干，并从服务器拉取到本地，格式如下,`local_dir`可选默认为*/Users/zxb/codereview*
```bash
   sh pull_codereview.sh branches_file [local_dir]
```
*branches_file*的文件格式如下，每个一行，目录和url空格分隔
```
intl-risk http://svn.alibaba-inc.com/repos/ali_express/risk/apps/service/intl-risk/branches/20130329_240255_1
risk/modules/risk/adaptor http://svn.alibaba-inc.com/repos/ali_express/risk/modules/risk/adaptor/branches/20130329_240255_1
risk/modules/risk/service http://svn.alibaba-inc.com/repos/ali_express/risk/modules/risk/service/branches/20130329_240255_1
share/intl-base-ext http://svn.alibaba-inc.com/repos/ali_express/share/intl-base-ext/branches/20130407_240255_1
```
生成的目录结构如下：
```
drwxr-xr-x 10 zxb staff 340  4  7 19:25 intl-risk/
drwxr-xr-x 10 zxb staff 340  4  7 19:26 intl-risk-trunk/
drwxr-xr-x  5 zxb staff 170  4  7 19:26 risk-modules-risk-adaptor/
drwxr-xr-x  5 zxb staff 170  4  7 19:19 risk-modules-risk-adaptor-trunk/
drwxr-xr-x  6 zxb staff 204  4  7 19:26 risk-modules-risk-service/
drwxr-xr-x  6 zxb staff 204  4  7 19:20 risk-modules-risk-service-trunk/
drwxr-xr-x  4 zxb staff 136  4  7 19:26 share-intl-base-ext/
drwxr-xr-x  4 zxb staff 136  4  7 19:26 share-intl-base-ext-trunk/
```
