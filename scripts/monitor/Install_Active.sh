#!/usr/bin/env bash
# Only RHEL system is supported
# Version: 2.0

SERVER_ADDRESS=$1

#Set Monitor ADDRESS
if [[ $SERVER_ADDRESS == '' ]];then SERVER_ADDRESS='node.connect.itan90.cn';fi

function GET_OS_Version() {
    OS_Version=$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/')
}

function INIT_OS() {
  # disabled SELinux
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
}

function GET_OS_STATUS() {
Processes=$(ps -ef|grep -v grep|grep zabbix|wc -l)
if [[ $Processes != '0' ]];then echo $(hostname -i ) 'Agent process already exists in the system!!!';exit 1;fi
}

function Install_5() {
    curl -O http://mirrors.itan90.cn/monitor/rpm/zabbix-agent-5.0.2-1.el5.x86_64.rpm
    rpm -ivh zabbix-agent-5.0.2-1.el5.x86_64.rpm &>/dev/null
    if [[ $? != '0' ]];then echo $(hostname -i ) 'Install failed!!!';fi
    service zabbix-agent start
    chkconfig --level 2345 zabbix-agent on
    /etc/init.d/zabbix-agent restart
}

function Install_6() {
    curl -O http://mirrors.itan90.cn/monitor/rpm/zabbix-agent-5.0.2-1.el6.x86_64.rpm
    rpm -ivh zabbix-agent-5.0.2-1.el6.x86_64.rpm &>/dev/null
    if [[ $? != '0' ]];then echo $(hostname -i ) 'Install failed!!!';fi
    service zabbix-agent start
    chkconfig --level 2345 zabbix-agent on
    /etc/init.d/zabbix-agent restart
}

function Install_7() {
    curl -O http://mirrors.itan90.cn/monitor/rpm/zabbix-agent-5.0.2-1.el7.x86_64.rpm
    rpm -ivh zabbix-agent-5.0.2-1.el7.x86_64.rpm &>/dev/null
    if [[ $? != '0' ]];then echo $(hostname -i ) 'Install failed!!!';fi
    systemctl start zabbix-agent
    systemctl enable zabbix-agent
    systemctl restart zabbix-agent
}


function Restart_AGENT56() {
  /etc/init.d/zabbix-agent restart
}

function Restart_AGENT7() {
  systemctl restart zabbix-agent
}

function Configure() {
cat << EOF > /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$SERVER_ADDRESS
ServerActive=$SERVER_ADDRESS
HostnameItem=system.hostname
HostMetadata=Active
Include=/etc/zabbix/zabbix_agentd.d/*.conf
UnsafeUserParameters=1
EOF
}

function AGENT_RUN() {
  STATUS=$(ss -ntl|grep 10050|head -1|awk '{print $1}'|wc -l)
  if [[ $STATUS -eq 1 ]];then echo $(hostname -i ) 'Install OK!!!';else echo $(hostname -i ) 'Install failed!!!';fi
}

function AGENT_Install() {
#Install_AGENTR
if [[ $OS_Version == 5 ]]; then
  Install_5
  Configure
  Restart_AGENT56
elif [[ $OS_Version == 6 ]]; then
  Install_6
  Configure
  Restart_AGENT56
elif [[ $OS_Version == 7 ]]; then
  Install_7
  Configure
  Restart_AGENT7
else
  echo $(hostname -i ) 'ERROR!Unsupported system version...'
fi
}


function Include_Monitor() {
    # 进程监控
    curl -s -O http://mirrors.itan90.cn/monitor/monitor.d/process_monitor.tar.gz &>/dev/null
    tar zxf process_monitor.tar.gz -C /etc/zabbix/zabbix_agentd.d/ && rm -rf process_monitor.tar.gz
    echo "已成功配置自动发现进程监控配置!"

    # 任务计划管理
    cd /usr/src && curl -s -O "http://mirrors.itan90.cn/monitor/monitor.d/Install_crond_manager.sh" && chmod +x Install_crond_manager.sh && ./Install_crond_manager.sh
    echo "已成功配置统一Crond管理探针!"
    
    # 重启探针
    Restart_AGENT7
}

function CLEAR_FILE() {
    rm -rf zabbix-agent*.rpm
    unlink $0
}


# Run Scripts
INIT_OS
GET_OS_Version
GET_OS_STATUS
AGENT_Install
AGENT_RUN
Include_Monitor
CLEAR_FILE
