#!/usr/bin/env bash
# register: curl -s https://mirrors.itan90.cn/scripts/monitor/prometheus/register_linux_Intranet.sh | bash
# unregister: curl -X PUT http://${monitor_center_server}/v1/agent/service/deregister/{id}

idc='本地云'
region='中国-上海市'
exporter_path='/app'
exporter_version='1.6.1'
host_name=$(hostname|cut -d'.' -f1)
host_addr=$(hostname -I|awk '{print $1}')
consul_server='42.192.186.124:8500'

# cpu platform
if [[ $(uname -m) == 'x86_64' ]];then
  cpu_platform='amd64'
elif [[ $(uname -m) == 'aarch64' ]];then
  cpu_platform='arm64'
else
  echo 'Unsupported'
  exit 1
fi

if [[ ! -d ${exporter_path}/node_exporter ]];then
        docker rm -f node-exporter &>/dev/null
        mkdir -p ${exporter_path}
        curl -so /tmp/node_exporter-v${exporter_version}.tar.gz \
        https://mirrors.itan90.cn/scripts/monitor/prometheus/resouce/node_exporter-${exporter_version}.linux-${cpu_platform}.tar.gz \
        && tar zxvf /tmp/node_exporter-v${exporter_version}.tar.gz -C ${exporter_path} \
        && mv ${exporter_path}/node_exporter/node_exporter.service /etc/systemd/system/ \
        && systemctl daemon-reload \
        && systemctl enable node_exporter --now
fi

curl -XPUT -d \
        '{"id": "'"${host_name}"'",
        "name": "linux-internal",
        "address": "'"${host_addr}"'",
        "port": 9100,"Meta": {"country": "'"${region}"'",
        "idc": "'"${idc}"'",
        "app": "'"${host_name}"'",
        "ip": "'"${host_addr}"'"},
        "tags": ["linux-internal"],
        "checks": [{"http": "'"http://${host_addr}:9100/metrics"'",
        "interval": "35s","timeout": "60s"}]}' http://${consul_server}/v1/agent/service/register
