#!/bin/bash
# sync source code from one local reposity  to another local reposity

while true
do
  echo -n  "Please input source path:"
  read src
  #echo "src:$src"
  
  if [ -d $src ];then
     if [ ${src:(-1)} != "/" ];then
	src="$src/"
     fi
    break 
  fi
done

while true
do
  echo -n  "Please input last update version:"
  read last_version
  
  if [ $last_version ];then
    break 
  fi
done

while true
do
  echo -n  "Please input destination path:"
  read dst
  #echo "dst:$dst"

  if [ -d $dst ];then
     if [ ${dst:(-1)} != "/" ];then
	dst="$dst/"
     fi
     break
  fi
done

work_dir=`pwd`
cd $src
git diff $last_version head --name-status > $work_dir/change_list.log
cd $work_dir
while read line
do
  # echo "$line"
  myflag=`echo $line|awk -F ' ' '{print $1}'`
  myfile=`echo $line|awk -F ' ' '{print $2}'`
  # echo "$myflag::$myfile"
  src_file="$src$myfile"
  dest_file="$dst$myfile"
  # echo "src_file:$src_file"
  # echo "dest_file:$dest_file"
  if [ $myflag == "D" ]; then
     echo "[delete] $dest_file"
     rm -f $dest_file
  else
     file_name=`echo $dest_file|awk -F '/' '{print $NF}'`
     ((parent_len = ${#dest_file} - ${#file_name} - 1))
     parent=${dest_file:0:$parent_len}
     # echo "parent:$parent"
     
     if [ ! -d "$parent" ]; then
	mkdir -p $parent
     fi
     cp -f  $src_file $dest_file 
     
     if [ $myflag == "A" ]; then
        echo "[add] $dest_file"
     elif [ $myflag == "M" ]; then
        echo "[modify] $dest_file"
     fi
  fi
done < change_list.log

rm -f change_list.log
