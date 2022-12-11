#!/usr/bin/env bash

idc=$1
region=$2
monitor_center_server=$3
hostname=$(hostname|cut -d'.' -f1)
os_address_external=$(curl -4s ip.sb)
if [[ $monitor_center_server == '' ]];then monitor_center_server='42.192.186.124:8500';fi

docker ps &>/dev/null
if [ $? != 0 ]; then echo "[ERROR] host: ${hostname} docker not runing";exit 1;fi
docker rm -f node-exporter
docker run -d -p 9100:9100 \
	-v "/proc:/host/proc:ro" \
	-v "/sys:/host/sys:ro" \
 	-v "/:/rootfs:ro" \
 	--net="host" \
 	--restart=always \
 	--name node-exporter \
	registry.cn-hangzhou.aliyuncs.com/bohai_repo/node-exporter:1.3.1

curl -XPUT -d \
	'{"id": "'"${hostname}"'",
	"name": "linux",
	"address": "'"${os_address_external}"'",
	"port": 9100,"Meta": {"country": "'"${region}"'",
	"idc": "'"${idc}"'",
	"ip": "'"${os_address_external}"'"},
	"tags": ["linux"],
	"checks": [{"http": "'"http://${os_address_external}:9100/metrics"'",
	"interval": "35s","timeout": "60s"}]}' http://${monitor_center_server}/v1/agent/service/register

unlink $0