#!/bin/bash

homeDir=/Users/zxb/codereview
if [ $2 ];then
  homeDir=$2
fi
cd $homeDir

while read line
do
  dir=`echo $line|awk -F ' ' '{print $1}'`
  url=`echo $line|awk -F ' ' '{print $2}'`
  dir=`echo ${dir//\//-}`
  echo "dir:$dir"
  echo "url:$url"
  
  rm -rf $dir
  svn co $url $dir

  trunkDir="$dir-trunk"
  trunkUrl=`echo $url|awk -F 'branches' '{print $1}'`
  trunkUrl="$trunkUrl""trunk"
  echo "trunkDir:$trunkDir"
  echo "trunkUrl:$trunkUrl"

  if [ -d $trunkDir ];then
    cd $trunkDir
    svn up 
    cd ..
  else
    svn co $trunkUrl $trunkDir
  fi

done < $1
