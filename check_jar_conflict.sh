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

echo "[info] get all dependencies jar and check conflicted class files"
dep_jar_list=`cat dt |grep INFO|grep jar|grep compile|awk -F '(' '{print $1}'|awk -F ' ' '{print $NF}'|awk -F ':' '{gsub(/\./,"/",$1);print $1"/"$2"/"$4"/"$2"-"$4"."$3}'|sort|uniq`
 
total=0
declare -A jar_map
for dep_jar in $dep_jar_list
do
  dep_jar="$M2_REPO$dep_jar"
  #echo "[debug] dep_jar: $dep_jar"
  if [ -f $dep_jar ]; then

     #list all classes in jar 
     class_list=`jar -tvf $dep_jar|grep class$|awk -F ' ' '{print $8}'`
     for class in $class_list
     do      

      jar_path=${jar_map[$class]} 
      if [[ -z $jar_path  ]]; then
        jar_map[$class]="$dep_jar"

      # ignore same path jars
      elif [[ $jar_path != $dep_jar ]]; then
        # cut the gid and aid part
        suffix1=`echo $jar_path|awk -F '/' '{print $(NF-1)$NF}'` 
        ((len1=${#jar_path} - ${#suffix1} - 2))
        gaid1=${jar_path:0:$len1} 

        suffix2=`echo $dep_jar|awk -F '/' '{print $(NF-1)$NF}'` 
        ((len2=${#dep_jar} - ${#suffix2} - 2)) 
        gaid2=${dep_jar:0:$len2} 

        # ignore jars that gid and aid are same
        if [[ $gaid1 != $gaid2 ]]; then
          total=$(( $total + 1 ))
          echo "[warn] conflict class is $class"
          echo "[warn] 1: $dep_jar"
          echo "[warn] 2: $jar_path"
          echo " "  
          break 
        fi
      fi
     done 
  fi
done

echo "[warn] total conflicted jar  is $total"

#remove the temp dependency tree file
rm dt