#!/bin/bash
## 下载docker-ce镜像源并安装

cd /etc/yum.repos.d/ && wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum install -y docker-ce-18.09.9 docker-compose && systemctl enable docker && systemctl start docker

mkdir -p /data/docker

## 配置镜像加速器
cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": ["https://ub816mdv.mirror.aliyuncs.com"],
    "graph":"/data/docker",
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

## 重启docker服务
systemctl  daemon-reload && systemctl restart docker
