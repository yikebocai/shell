#!/bin/bash

ignore_classes=("java" "sun" "com.alibaba.service" "com.alibaba.turbine" "com.alibaba.common" "com.alibaba.webx" "org.apache.commons" "com.alibaba.intl.commons" "org.junit" "org.apache.log4j" "com.alibaba.intl.risk.ruleengine")

#update bash to v4.2 http://zengrong.net/post/1830.htm
M2_REPO=$1
if [ ${M2_REPO:(-1)} == "/" ]; then
   M2_REPO=${M2_REPO:0:${#M2_REPO}-1}
fi
echo "[info] maven repository is $M2_REPO"

echo "[info] generate dependency tree"
cd $2/all
#mvn dependency:tree > dt
build=`cat dt|grep 'BUILD ERROR'`
if [[ -n $build ]]; then
   echo "[error] build error,please check first"
   exit
fi

echo "[info] get all direct dependency jar's absolutely path"
dep_jar_list=`cat dt |grep '] +-'|grep -v war$|awk -F ' ' '{print $3}'|awk -F ':' '{gsub(/\./,"/",$1);print "/Users/zxb/.m2/repository/"$1"/"$2"/"$4"/"$2"-"$4"."$3}'|sort|uniq`

echo "[info] get all classes of a jar"
declare -A jar_map
for dep_jar in $dep_jar_list
do
   if [ -f $dep_jar ]; then
     #echo "[debug] $dep_jar"

     #list all classes in jar 
     class_list=`jar -tvf $dep_jar|grep class$|awk -F ' ' '{print $8}'`
     for class in $class_list
     do 
       jar_map[$class]="$dep_jar"
       #echo "[debug]    $class"
     done 
   fi
done

echo "[info] list all java files,parse import class,get it's jar path"
list=`find ..|grep src|grep -v Test.java$|grep java$`
for line in $list 
do
   #echo $line
   if [ -d $line ]; then
      continue
   fi  

   #list all import
   import_list=`grep ^import $line`
   for import_line in $import_list
   do 
       if [ ${import_line:(-1)} == ";" ];then
          #remove last charactor,and replace all '.' to '/',and append '.class'
          ref_class=${import_line:0:${#import_line}-1}
          #ignore some common class
          flag=0
          for ignore in ${ignore_classes[@]}
          do 
             ignored=`echo $ref_class|grep ^$ignore`
             if [ ${#ignored} -gt 1 ]; then
                flag=1
                break
             fi
          done
          if [ $flag -eq 1 ]; then
             #echo "ignore:$ref_class"
             continue
          fi

          ref_class=${ref_class//./\/}
          ref_class="$ref_class"".class"
          #echo $ref_class

          jar_path=${jar_map[$ref_class]}
          if [[ -z $jar_path  ]]; then
                echo "[warn] java:$line"
                echo "[warn] import:$import_line"
                echo "[warn] "  
          fi
       fi
   done
done

