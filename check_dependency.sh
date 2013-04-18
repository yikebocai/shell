#!/bin/bash
#update bash to v4.2 http://zengrong.net/post/1830.htm
M2_REPO=$1
if [ ${M2_REPO:(-1)} == "/" ]; then
   M2_REPO=${M2_REPO:0:${#M2_REPO}-1}
fi
echo "[info] maven repository is $M2_REPO"

echo "[info] generate dependency tree"
cd $2/all
mvn dependency:tree > dt
build=`cat dt|grep 'BUILD ERROR'`
if [[ -n $build ]]; then
   echo "[error] build error,please check first"
   exit
fi

echo "[info] parse all direct dependency jar's absolutely path"
dep_jar_list=`cat dt |grep '] +-'|awk -F ' ' '{print $3}'|awk -F ':' '{gsub(/\./,"/",$1);print "/Users/zxb/.m2/repository/"$1"/"$2"/"$4"/"$2"-"$4"."$3}'`
declare -A dep_jar_map
for dep_jar in $dep_jar_list
do
  dep_jar_map[$dep_jar]="Y"
done

echo "[info] find all dependency classes,wait for some minutes ..."
mvn eclipse:clean eclipse:eclipse > /dev/null & 
cd ..
declare -A jar_map
classpath_list=`find .|grep  classpath$`
for classpath in $classpath_list 
do
   #echo $classpath
   while read line
   do
     #parse jar path
     kind=`echo $line|grep kind|grep var`
     #echo $kind
     if [ -n "$kind" ]; then
        jar_path=`echo $line|awk -F ' ' '{print $3}'|awk -F '=' '{print $2}'`
        jar_path=${jar_path%\"*}
        jar_path=${jar_path:1:${#jar_path}-1}
        jar_path=${jar_path/M2_REPO/$M2_REPO}
        #echo "\t$jar_path"
        
        #list all classes in jar 
        class_list=`jar -tvf $jar_path|grep class$|awk -F ' ' '{print $8}'`
        for class in $class_list
        do 
           jar_map[$class]="$jar_path"
           #echo "\t\t$class"
        done 
     fi
   done < $classpath
done


echo "[info] list all java files,parse import class,get it's jar package"
list=`find .|grep src|grep java$`
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
          ref_class=${ref_class//./\/}
          ref_class="$ref_class"".class"
          #echo $ref_class

          jar_path=${jar_map[$ref_class]}
          if [ ${#jar_path} -gt 0 ]; then
             isHit=${dep_jar_map[$jar_path]}
             if [[ -z $isHit ]]; then
                echo "[warn] java:$line"
                echo "[warn] import:$import_line"
                echo "[warn] jar:$jar_path"
                echo "[warn] "  
             fi
          fi
       fi
   done
done

