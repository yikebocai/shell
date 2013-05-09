#!/bin/bash
ignore_lines=("未提测","是","")
homeDir=/Users/zxb/codereview
if [ $2 ];then
  homeDir=$2
fi
cd $homeDir

#define dir and url
dir=""
url=""
while read line
do
  #ignore  invalid lines
  for ignore in ${ignore_lines[@]}
  do
     if [ "$line" == $ignore ]; then
        continue
     fi
  done
  
  if [ "${line:0:4}" == "http" ]; then
     url=$line
  elif [ ${#line} -gt 2 ]; then
     dir=$line
     continue
  else
     continue
  fi

  #dir=`echo $line|awk -F ' ' '{print $1}'`
  #url=`echo $line|awk -F ' ' '{print $2}'`
  dir=`echo ${dir//\//-}`
  
  echo "dir:$dir"
  echo "url:$url"
  if [ ${#dir} -lt 2 ]; then
     echo "[error] dir is invalid"
  elif [ ${#url} -lt 10 ]; then
     echo "[error] url is invalid"
  fi
  
  rm -rf $dir
  svn co $url $dir

  trunkDir="$dir-trunk"
  trunkUrl=`echo $url|awk -F 'branches' '{print $1}'`
  trunkUrl="$trunkUrl""trunk"
  echo "trunkDir:$trunkDir"
  echo "trunkUrl:$trunkUrl"
  echo ""

  if [ -d $trunkDir ];then
    cd $trunkDir
    svn up 
    cd ..
  else
    svn co $trunkUrl $trunkDir
  fi


done < $1
