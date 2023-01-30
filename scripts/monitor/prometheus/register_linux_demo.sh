#!/usr/bin/env bash
# unregister: curl -X PUT http://42.192.186.124:8500/v1/agent/service/deregister/$(hostname -I|awk '{print $1}')


exporter_version='1.3.1'
monitor_center_server=$1
host_addr=$(hostname -I|awk '{print $1}')
if [[ $monitor_center_server == '' ]];then monitor_center_server='42.192.186.124:8500';fi

docker ps &>/dev/null
if [ $? != 0 ]; then echo "[ERROR] host: $hostname docker not runing";exit 1;fi
docker rm -f node-exporter
docker run -d -p 9100:9100 \
	-v "/proc:/host/proc:ro" \
	-v "/sys:/host/sys:ro" \
 	-v "/:/rootfs:ro" \
 	--restart=always \
 	--name node-exporter \
	registry.cn-hangzhou.aliyuncs.com/bohai_repo/node-exporter:${exporter_version}

curl -XPUT -d \
	'{"id": "'"${host_addr}"'","name": "linux",
	"address": "'"${host_addr}"'","port": 9100,
	"Meta": {"ip": "'"${host_addr}"'"},
	"checks": [{"http": "'"http://${host_addr}:9100/metrics"'",
	"interval": "35s","timeout": "60s"}]}' http://${monitor_center_server}/v1/agent/service/register
