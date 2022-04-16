## 说明

用于存储监控配置,包括但不限于以下几点:

- 监控子配置
- 监控脚本

## 规范

*制定一些规范性的要求;确保客户端无需人为干预完成监控配置*

**一、压缩包方式交付(.tar.gz);其压缩包根目录下包含:**

- 脚本文件夹文件: `itemname`_monitor_scripts
- 监控子配置文件名: `itemname`_monitor.conf

```
例如:
[root@devops ~ ]# cd /etc/zabbix/zabbix_agentd.d/
[root@devops ~ ]# tar zxf process_monitor.tar.gz
[root@devops ~ ]# tree 
.
├── process_monitor.conf
└── process_monitor_scripts
    ├── check_process.sh
    └── get_process.sh

1 directory, 3 files

```
**二、客户端获取:**

- 客户端可通过访问域名:http://mirrors.itan90.cn/monitor/monitor.d/itemname.tar.gz 直接下载该配置

```
例如:
curl -s -O http://mirrors.itan90.cn/monitor/monitor.d/process_monitor.tar.gz
```
