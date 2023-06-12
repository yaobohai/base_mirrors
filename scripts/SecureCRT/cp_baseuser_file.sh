#!/bin/sh

file_name=$1
if [[ -z ${file_name} ]];then echo "no input file";exit 1;fi

base_user=$(w|awk '{print $1}'|sed -n 3p)
mv "/home/${base_user}/$file_name" ./