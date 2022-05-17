#!/usr/bin/env bash

monitor_center_server=$1
mirrors_center_server='raw.githubusercontent.com/yaobohai/base_mirrors/develop'

if [[ $monitor_center_server == '' ]];then monitor_center_server='mirrors.itan90.cn';fi

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
  os_address_external=$(curl -4s ip.sb)
  os_address_internal=$(hostname -I|awk '{print $1}')
  os_type=$(cat /etc/redhat-release|awk '{print $1,$2}')
  os_version=$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')
}

function install_base_pack() {
  /bin/curl -so /etc/docker/daemon.json https://${mirrors_center_server}/scripts/conf/docker/daemon.json
  /bin/curl -so /etc/yum.repos.d/docker-ce.repo https://${mirrors_center_server}/scripts/conf/docker/docker-ce.repo
  /bin/curl -so /opt/ops_tools/update_hosts https://${mirrors_center_server}/scripts/other/update_hosts/update_hosts
  /bin/curl -so /tmp/ops_tools/zabbix-agent-5.0.2-1.el7.x86_64.rpm https://${mirrors_center_server}/scripts/monitor/rpm/zabbix-agent-5.0.2-1.el7.x86_64.rpm
  /usr/bin/yum clean all
  /usr/bin/yum makecache
  /usr/bin/yum -y update
  /usr/bin/yum -y install sl gcc gcc-c++ \
  vim wget ntp ntpdate docker-ce-18.09.9 docker-compose
  /usr/bin/yum -y localinstall /tmp/ops_tools/zabbix-agent-5.0.2-1.el7.x86_64.rpm
}

function optimize_base_system() {
  # disabled SELinux
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

  rm -rf /etc/localtime
  echo 'Zone=Asia/Shanghai' > /etc/sysconfig/clock
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  hwclock -w
  ntpdate -u ntp2.aliyun.com

  # disable firewalld
  systemctl stop firewalld
  systemctl disable firewalld

  cat > /etc/sysctl.conf <<EOF
    vm.swappiness = 0
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
    ##https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4396e46187ca5070219b81773c4e65088dac50cc
    ##linux在高版本内核中移除了这个参数
    #net.ipv4.tcp_tw_recycle = 1
    net.ipv4.tcp_fin_timeout = 10
    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    net.ipv6.conf.lo.disable_ipv6 = 1
    net.ipv4.conf.lo.arp_announce=2
    vm.max_map_count=262144
    vm.overcommit_memory = 1
    net.ipv4.ip_forward = 1
    net.netfilter.nf_conntrack_max = 524288
    net.nf_conntrack_max = 524288
    net.core.somaxconn = 1024
EOF

  cat > /etc/zabbix/zabbix_agentd.conf <<EOF
    PidFile=/var/run/zabbix/zabbix_agentd.pid
    LogFile=/var/log/zabbix/zabbix_agentd.log
    LogFileSize=0
    Server=$monitor_center_server
    ServerActive=$monitor_center_server
    Hostname=$os_address_external
    HostMetadataItem=system.uname
    Include=/etc/zabbix/zabbix_agentd.d/*.conf
    UnsafeUserParameters=1
EOF

  useradd appuser
  usermod -a -G docker appuser
  echo 'appuser ALL=(ALL)       NOPASSWD:ALL' >> /etc/sudoers.d/appuser
  chmod -w /etc/sudoers.d/appuser

  mkdir /home/appuser/.ssh/
  curl -sk https://${mirrors_center_server}/scripts/init/ssh_keys > /home/appuser/.ssh/authorized_keys

  chmod 700 /home/appuser/.ssh
  chmod 600 /home/appuser/.ssh/authorized_keys
  chown -R appuser:appuser /home/appuser/

  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  echo 'RSAAuthentication yes' >> /etc/ssh/sshd_config
  echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
}

function include_extra_conf() {
  # 进程监控
  curl -s -O https://${mirrors_center_server}/scripts/monitor/monitor.d/process_monitor.tar.gz &>/dev/null
  tar zxf process_monitor.tar.gz -C /etc/zabbix/zabbix_agentd.d/ && rm -rf process_monitor.tar.gz

  # hosts解析订阅
  echo '* * * * * /bin/bash /opt/ops_tools/update_hosts' >> /var/spool/cron/root
  chmod +x /opt/ops_tools/update_hosts

  # enable_extra_service
  systemctl restart sshd zabbix-agent docker crond
  systemctl enable sshd zabbix-agent docker crond
}

function main() {
  make_base_dir
  system_base_info
  install_base_pack
  optimize_base_system
  include_extra_conf
  unlink $0
  reboot
}

main