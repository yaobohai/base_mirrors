#!/usr/bin/env bash

# 文件路径
FILE_URL='http://mirrors.itan90.cn/monitor/monitor.d/crond_manager.tar.gz'

# gRPC服务端地址
SERVER_ADDR='node.connect.itan90.cn:5005'

# 安装路径
WORKSPACE='/app/crond_manager'
if [[ ! -d ${WORKSPACE} ]];then mkdir -p ${WORKSPACE};fi

curl -s -O ${FILE_URL} &>/dev/null

tar zxf crond_manager.tar.gz -C ${WORKSPACE}

# 配置文件
cat << EOF > ${WORKSPACE}/conf/crond_manager.ini
[jiacrontabd]
verbose_job_log     = false
listen_addr         = :5004
admin_addr          = ${SERVER_ADDR}
auto_clean_task_log = true
log_level           = warn
log_path            = ./logs
user_agent          = jiacrontabd
driver_name         = sqlite3
dsn                 = ${WORKSPACE}/data/jiacrontabd.db?cache=shared
client_alive_interval = 10
EOF

# 启动配置
cat << EOF > ${WORKSPACE}/startup.sh
#!/usr/bin/env bash
nohup ${WORKSPACE}/sbin/crond_manager -config ${WORKSPACE}/conf/crond_manager.ini &>/dev/null &
EOF

chmod +x ${WORKSPACE}/startup.sh && /bin/bash ${WORKSPACE}/startup.sh

if [[ $? == 0 ]]; then
  echo "/bin/bash ${WORKSPACE}/startup.sh" >> /etc/rc.d/rc.local
  chmod +x /etc/rc.d/rc.local
fi

unlink crond_manager.tar.gz
unlink $0
