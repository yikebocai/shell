#!/bin/bash

#update bash to v4.2 http://zengrong.net/post/1830.htm
M2_REPO=~/.m2/repository/
echo "[info] maven repository is $M2_REPO"

echo "[info] generate dependency tree"
mvn dependency:tree > dt
build=`cat dt|grep 'BUILD ERROR'`
if [[ -n $build ]]; then
   echo "[error] build error,please check first"
   exit
fi

echo "[info] get all dependencies jar"
dep_jar_list=`cat dt |grep INFO|grep jar|grep compile|awk -F '(' '{print $1}'|awk -F ' ' '{print $NF}'|awk -F ':' '{gsub(/\./,"/",$1);print $1"/"$2"/"$4"/"$2"-"$4"."$3}'|sort|uniq`

echo "[info] check all class files"
total=0
declare -A jar_map
for dep_jar in $dep_jar_list
do
  dep_jar="$M2_REPO$dep_jar"
  #echo "[debug] $dep_jar"
  if [ -f $dep_jar ]; then

     #list all classes in jar 
     class_list=`jar -tvf $dep_jar|grep class$|awk -F ' ' '{print $8}'`
     for class in $class_list
     do      

      jar_path=${jar_map[$class]}
      if [[ -z $jar_path  ]]; then
        jar_map[$class]="$dep_jar"
        #echo "[debug]    $class"    
      elif [[ $jar_path != $dep_jar ]]; then
        total=$(( $total + 1 ))
        echo "[warn] conflict class is $class"
        echo "[warn] 1 : $dep_jar"
        echo "[warn] 2 : $jar_path"
        echo " "  
        break
      fi
     done 
  fi
done

echo "[warn] total conflicted jar  is $total"

rm dt