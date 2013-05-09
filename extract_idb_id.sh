#!/bin/bash

while read line
do
  if [ ${#line} -gt 2 ]; then
     echo $line
  fi
done< $1
