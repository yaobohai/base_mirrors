#!/usr/bin/env bash
# unregister: curl -X PUT http://${monitor_center_server}/v1/agent/service/deregister/{id}

idc=$1
region=$2
app=$3
exporter_path='/app'
exporter_version='1.6.1'
monitor_center_server='42.192.186.124:8500'
hostname=$(hostname|cut -d'.' -f1)
os_address_external=$(curl -4s ip.gs)

docker rm -f node-exporter
rm -rf  ${exporter_path}/node_exporter
mkdir -p ${exporter_path}
curl -so /tmp/node_exporter-v${exporter_version}.tar.gz \
https://mirrors.itan90.cn/scripts/monitor/prometheus/resouce/node_exporter-${exporter_version}.tar.gz \
&& tar zxvf /tmp/node_exporter-v${exporter_version}.tar.gz -C ${exporter_path} \
&& mv ${exporter_path}/node_exporter/node_exporter.service /etc/systemd/system/ \
&& systemctl daemon-reload \
&& systemctl enable node_exporter --now

curl -XPUT -d \
	'{"id": "'"${hostname}"'",
	"name": "linux",
	"address": "'"${os_address_external}"'",
	"port": 9100,"Meta": {"country": "'"${region}"'",
	"idc": "'"${idc}"'",
	"app": "'"${app}"'",
	"ip": "'"${os_address_external}"'"},
	"tags": ["linux"],
	"checks": [{"http": "'"http://${os_address_external}:9100/metrics"'",
	"interval": "35s","timeout": "60s"}]}' http://${monitor_center_server}/v1/agent/service/register