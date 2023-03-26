#!/usr/bin/env bash

mirrors_center_server='mirrors.itan90.cn'
devops_scripts_version='20220919-SNAPSHOT'

if [ $(id -u) != 0 ];then echo "You must use the root account to allow scripts";exit 1;fi

function match_content(){ if ! grep -qF "${content}" ${file_path}; then echo "${content}" >> ${file_path};fi }

function make_base_dir() {
  local dirs=(
      # system
      '/root/.ssh/'
      # docker
      '/etc/docker/'
      '/data/docker'
      '/root/.docker/'
      '/etc/systemd/system/docker.service.d/'
      # ops_tools
      '/opt/ops_tools/'
      '/tmp/ops_tools/'
      '/var/spool/cron/'
  )
  local dirs_num=${#dirs[@]}
  for ((i=0;i<dirs_num;i++));{ mkdir -p ${dirs[i]} ;}
}

function system_base_info() {
  os_mem_total=$(free -m|grep 'Mem'|awk '{print $2}')
  os_cpu_total=$(lscpu|grep 'Core(s) per socket'|awk '{print $4}')
  os_address_external=$(curl -4s ip.gs)
  os_address_internal=$(hostname -I|awk '{print $1}')
  os_type=$(cat /etc/redhat-release|awk '{print $1,$2}')
  os_version=$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')
}

function install_base_pack() {
  /bin/curl -so /etc/docker/daemon.json https://${mirrors_center_server}/scripts/conf/docker/daemon.json
  /bin/curl -so /etc/yum.repos.d/docker-ce.repo https://${mirrors_center_server}/scripts/conf/docker/docker-ce.repo
  /bin/curl -so /opt/ops_tools/update_hosts https://${mirrors_center_server}/scripts/other/update_hosts/update_hosts
  /usr/bin/yum clean all
  /usr/bin/yum makecache
  /usr/bin/yum -y update
  /usr/bin/yum -y install sudo gcc gcc-c++ \
  vim wget ntp ntpdate docker-ce-18.09.9 docker-compose \
  tree epel-release telnet ftp mysql git net-tools bash-completion \
  jq sysstat yum-utils device-mapper-persistent-data lvm2 htop
  chmod +x /opt/ops_tools/update_hosts
}

function optimize_base_system() {
  # enable service
  systemctl enable sshd docker crond --now
  
  # disabled SELinux
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

  rm -rf /etc/localtime
  content="Zone=Asia/Shanghai";file_path="/etc/sysconfig/clock";match_content
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  hwclock -w
  ntpdate -u ntp2.aliyun.com

  systemctl stop firewalld
  systemctl disable firewalld

cat << EOF > /etc/sysctl.conf
vm.swappiness = 10
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.conf.lo.arp_announce=2
vm.max_map_count=262144
vm.overcommit_memory = 1
net.ipv4.ip_forward = 1
net.netfilter.nf_conntrack_max = 524288
net.nf_conntrack_max = 524288
net.core.somaxconn = 1024
EOF

  useradd appuser
  usermod -a -G docker appuser
  content="appuser ALL=(ALL)       NOPASSWD:ALL";file_path="/etc/sudoers.d/appuser";match_content
  chmod -w /etc/sudoers.d/appuser

  mkdir -p /home/appuser/.ssh/
  curl -sk https://${mirrors_center_server}/scripts/init/ssh_keys > /home/appuser/.ssh/authorized_keys

  chmod 700 /home/appuser/.ssh
  chmod 600 /home/appuser/.ssh/authorized_keys
  chown -R appuser:appuser /home/appuser/

  sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
  sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
}

function include_extra_conf() {

  content="* * * * * /bin/bash /opt/ops_tools/update_hosts";file_path="/var/spool/cron/root";match_content
  content="*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com";file_path="/var/spool/cron/root";match_content

  # export idc='华为云' ; export region='中国-上海市' ; export app='v2ray'
  if [[ $idc == '' ]];then idc='未知厂商';fi;if [[ $region == '' ]];then region='未知地域';fi
  curl -so register_linux.sh https://${mirrors_center_server}/scripts/monitor/prometheus/register_linux.sh
  chmod +x register_linux.sh && bash register_linux.sh  $idc $region $app

  curl -so /tmp/add_host https://${mirrors_center_server}/scripts/devops/add_host_${devops_scripts_version}
  chmod +x /tmp/add_host && /tmp/add_host ${os_address_external} ${os_address_external} appuser 22
  
  title="新实例初始化完成提醒"
  body="厂商: ${idc} 地域: ${region} 应用: ${app} 规格: ${os_mem_total}MiB/${os_cpu_total}C"
  curl -X POST -H "Content-Type:application/json" -d '{"to":"2695476342@qq.com","subject":"'"${title}"'","body":"'"${body}"'"}' https://notify.itan90.cn/mail/admin
}

function main() {
  make_base_dir
  system_base_info
  install_base_pack
  optimize_base_system
  include_extra_conf
}

main;reboot
