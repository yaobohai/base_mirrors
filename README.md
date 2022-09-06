## 2022年09月06日 增加FRPC客户端

```shell
$ mkdir -p /app/frpc/
$ vim /app/frpc/frpc.ini

[common]
tcp_mux = true
protocol = tcp
admin_port = 7400
admin_addr = 0.0.0.0
dns_server = 114.114.114.114
server_addr = {{ .Envs.FRPS_ADDR }}
server_port = {{ .Envs.FRPS_PORT }}
admin_user = {{ .Envs.FRPC_USER }}
admin_pwd = {{ .Envs.FRPC_PASSWD }}

[demo]
privilege_mode = true
type = tcp
local_ip = 192.168.1.1
local_port = 80
remote_port = 8080
use_encryption = true
use_compression = true
```

```shell
# x86
docker run -itd --name=frpc --restart=always \
-p 7400:7400 \
-e FRPS_ADDR=你的服务端地址 \
-e FRPS_PORT=你的服务端端口 \
-e FRPC_USER=客户端管理用户 \
-e FRPC_PASSWD=客户端管理密码 \
-v /app/frpc/frpc.ini:/app/frpc/frpc.ini \
registry.cn-hangzhou.aliyuncs.com/bohai_repo/frpc:0.28.2

# arm
docker run -itd --name=frpc --restart=always \
-p 7400:7400 \
-e FRPS_ADDR=你的服务端地址 \
-e FRPS_PORT=你的服务端端口 \
-e FRPC_USER=客户端管理用户 \
-e FRPC_PASSWD=客户端管理密码 \
-v /app/frpc/frpc.ini:/app/frpc/frpc.ini \
registry.cn-hangzhou.aliyuncs.com/bohai_repo/frpc-arm:0.28.2
```

客户端管理UI: http://IP:7400 (配置WEB管理、热加载等)

![ADMIN_UI](https://resource.static.tencent.itan90.cn/mac_pic/2022-09-06/Hec0Vb.png)

## 2021年12月19日 增加远程下载工具 ⭐

1、安装Docker(已安装则可忽略)

```
yum -y install docker \
&& systemctl start docker \
&& systemctl enable docker
```

2、安装远程下载工具程序

```
首选地址：curl -s https://oss.itan90.cn/files/remote_download/init.sh|bash
备用地址：curl -s https://oss-1251604004.cos.ap-shanghai.myqcloud.com/files/remote_download/init.sh|bash
```

3、访问

```
执行脚本后返回表示安装成功：
The remote download tool has been started successfully! Access address is: http://xx.xx.xx.xx:8999

访问返回的地址后即可打开网页；默认存在50MB大小的文件用来测试下载速度
```

## 2021年10月01日 新增部署WARP支持

```
参考: https://itan90.cn/Cloudflare_WARP/
```

部分系统执行报错：RTNETLINK answers: Permission denied

大致意为系统内核参数中禁用了IPV6，解决方法如下：

```
$ vim /etc/sysctl.conf
# 增加以下参数
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.br-c52900509a5c.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.docker0.disable_ipv6 = 0
net.ipv6.conf.eth0.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0

$ sysctl -p
```

## 2021年09月29日 新增IP查询脚本 ⭐

```
$ curl -s -O http://mirrors.itan90.cn/scripts/other/ip_query && chmod +x ip_query && ./ip_query
# 执行后返回以下信息：
虚拟 IPV4 地址: 114.0.0.0.0
虚拟 IPV6 地址: 240e:388...
真实 IPV4 地址: 114.0.0.0.0
真实 IPV6 地址: 240e:388...
```

## 2021年09月10日 新增部署V2RAY脚本 ⭐

1、安装BBR加速 

```
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/scripts/net/bbr/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```

2、更新内核

```
输入以下代码。在弹出的界面选1，安装内核，安装完之后vps会重启，SSH会断开连接，重启等待1到2分钟，重新连接vps ssh，输入以下代码，在弹出的界面输入5，使用BBR

cd /usr/src && ./tcp.sh
```

3、安装V2RAY

```
# 输入以下代码
# 选择：1 回车因为脚本需要安装Nginx，比较慢，大概五六分钟，等待一下。过程中会提示需要输入域名，输入解析到本服务器的域名，然后回车 等即可
cd /usr/src && curl -O http://mirrors.itan90.cn/scripts/net/v2ray/v2ray_ws_tls.sh && chmod +x v2ray_ws_tls.sh && ./v2ray_ws_tls.sh
```

## 2021年08月23日 增加监控探针安装 ⭐

---

监控探针版本：5.0.2

监控服务端口：10050

监控服务地址：node.connect.itan90.cn (默认)

监控组件配置：<http://mirrors.itan90.cn/scripts/monitor/monitor.d/>

---

```
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/scripts/monitor/Install.sh" && chmod +x Install.sh && ./Install.sh

# 使用主动模式脚本
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/scripts/monitor/Install_Active.sh" && chmod +x Install_Active.sh && ./Install_Active.sh

# 使用其他服务地址
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/scripts/monitor/Install.sh" && chmod +x Install.sh && ./Install.sh 你的服务端地址
```

## 2021年07月03日 增加服务器初始化脚本

2022年05月18日 更新笔记

> 初始化基础环境清单

- 主机监控
- 进程监控
- 优化内核
- 时间同步
- DOCKER
- 基础工具包
- 域名解析订阅
- SSH-KEY登录
- DOCKER COMPOSE

```
# 国内
curl -s "https://mirrors.itan90.cn/scripts/init/main.sh" |bash

# 不执行监控部署
curl -s "https://mirrors.itan90.cn/scripts/init/main_no_monitor.sh" |bash
```


## 2021年07月02日 mirrors 信息发布建立
