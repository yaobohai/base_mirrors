#!/bin/bash
url='
http://应用地址:9303/actuator/health
'

for i in $url;do curl -s --speed-time 3 --speed-limit 1 $i &>/dev/null ;if [[ $? == 0 ]];then echo "$i PONG";else echo "$i cant't connect";fi;done
