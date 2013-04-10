#!/bin/bash

#list all java files
cd $1   #define scan dir
list=`find .|grep src|grep java$`
for line in $list 
do
   echo $line
   
   #list all import
   import_list=`grep ^import $line`
   for import_line in $import_list
   do 
       if [ ${import_line:(-1)} == ";" ];then
          #remove last charactor,and replace all '.' to '/',and append '.class'
          ref_class=${import_line:0:${#import_line}-1}
          ref_class=${ref_class//./\/}
          ref_class="$ref_class"".class"
          echo $ref_class
       fi
   done
done
