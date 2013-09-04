## 1. pull_codereview_branches.sh
>做Codereview时，经常需要把代码分支和它对应的主干拉到本地，然后使用文件比较工具，比如Mac下的DiffMerge来做代码变更对比，手工拉取非常不便，写了脚本来自动实现。唯一麻烦就是需要把分支拷贝到一个文件，然后才能执行shell命令。

自动从指定的文件中解析branches和它对应的主干，并从服务器拉取到本地，格式如下,`local_dir`可选默认为*/Users/zxb/codereview*
```bash
   sh pull_codereview_branches.sh branches_file [local_dir]
```
*branches_file*的文件格式如下，是直接从Aone里Copy出来的：
```
未提测
risk/modules/risk/keyword

http://svn.alibaba-inc.com/repos/ali_express/risk/modules/risk/keyword/branches/20130422_245137_1
是
			
未提测
risk/open/riskclient/client

http://svn.alibaba-inc.com/repos/ali_express/risk/open/riskclient/client/branches/20130425_245137_4
是
			
未提测
intl-risk
http://svn.alibaba-inc.com/repos/ali_express/risk/apps/service/intl-risk/branches/20130509_245137_4
	
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

## 2.check_dependency.sh
>最近发生几次间接依赖导致的主干代码编译失败的问题，原因都是因为在我们的应用代码使用了一个间接依赖进来的jar包的一个类，但这个间接依赖jar在别人升级时去掉了，导致我们应用编译失败。另外还看到很多不合理的工具类使用，比如StringUtil和StringUtils，有很多内部的jar中也自己实现这个东东，而我们实际上是想使用apache.common包中的工具类，在Eclipse中自动导入时，没有注意就导入了一个某个业务jar的工具类，别人在做升级时如果对该工具类做了修改，也会导致我们的应用编译失败。因此，想写一个shell脚本来自动检测依赖关系，把不正常的依赖类打印出来。

**基本思路**

1. 通过Maven命令`mvn dependency:tree`来首先生成应用的依赖关系
2. 解析生成的依赖关系文件，找出直接依赖的jar或car包
3. 找到Maven仓库中该jar或car包实际的绝对路径
4. 使用`jar -tvf`列表该jar或car中所有的class文件完整名
5. 将class文件名和对应的jar或car包放到Map中用于后面的快速查询
6. 使用`find .|grep java$`命令，找到应用中所有java源文件
7. 使用`cat xxx.java|grep ^import`命令找出该java源文件导入的所有类名
8. 把类名转成和jar中一样的表示形式，查询它是否在Map中存在
9. 如果存在说明不是间接依赖，否则打印该Java源文件路径和导入的类名

**使用方法**

指定Maven仓库路径和需要检查的应用所有目录
```
check_dependency.sh ~/.m2/repository/ ../intl-risk
```
如果编译失败显示如下内容，请先手工编译成功再招待上述命令
```
zmbp:shell zxb$ check_dependency.sh ~/.m2/repository/ ../intl-riskbops/
[info] maven repository is /Users/zxb/.m2/repository
[info] generate dependency tree
[error] build error,please check first
```
执行完毕，展示结果如下
```
[warn] java:../web/risk/src/java/com/alibaba/intl/riskbops/web/risk/viewobject/index/IndexVO.java
[warn] import:org.jfree.data.general.DefaultPieDataset;
[warn] 
[warn] java:../web/risk/src/java/com/alibaba/intl/riskbops/web/risk/viewobject/module/ObjectBinding.java
[warn] import:org.apache.http.client.ClientProtocolException;
[warn] 
[warn] java:../web/risk/src/java/com/alibaba/intl/riskbops/web/risk/viewobject/module/ObjectBinding.java
[warn] import:org.apache.http.client.HttpClient;
```
如果只更清楚地看所有间接依赖的类，可以执行如下命令
```
check_dependency.sh ~/.m2/repository/ ../intl-risk > cd.log
cat cd.log|grep import|sort|uniq
```

**说明**

1. 因为内部类没有生成单独的class文件，因此无法检测，会认为是间接依赖的jar引入的，请忽略
2. 如果一些基础框架虽然没有直接依赖，但能够确保它肯定在别的jar中会引入进来，可以修改源代码设置忽略的包名，如下所示：
```
ignore_classes=("java" "sun" "com.alibaba.service" "com.alibaba.turbine" "com.alibaba.common" "com.alibaba.webx" "or    g.apache.commons" "com.alibaba.intl.commons" "org.junit" "org.apache.log4j" "com.alibaba.intl.risk.ruleengine")
```

## 3.extract_idb_id.sh
从idb里查询出来的id，如果要从浏览器里Copy出来，你就会发现有一行很烦人的序号没有去掉，执行该脚本直接得到纯id号

## 4.check_jar_conflict.sh
>同一个jar包有可能会有不同的gid和aid，因此会导致jar包冲突，运行期引起不可预知的错误

实现原理：
* 使用`mvn dependency:tree`生成依赖关系树
* 找到关系树中每个jar包在maven仓库中的位置
* 使用`jar -tvf`得到每个jar中的class文件，并将class文件放到Map中
* 检查class文件是否已在其它jar中存在

注意事项：
* 保证项目编译能通过

使用方式：
* 把sh脚本考到顶级pom同一文件夹下
* 执行`./check_jar_conflict.sh`
 

