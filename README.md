## CloudFlare自选IP列表

- 每小时更新一次

点击跳转：[CloudFlare自选IP列表](https://mirrors.itan90.cn/ava_nodes/)

## 2022年12月22日 增加命令行文件共享脚本 

- 20MB/s峰值下行速度
- 支持IPV6并使用HTTPS加密请求
- 使用curl请求即可共享本地文件
- 使用定时清理策略 文件仅保留14天
- 尽量保持单个文件大小在100MB内 (Cloudflare限制)

使用 

```shell
# 使用IPV4请求
curl -4s https://transfer.init.ac/scripts/file.sh|bash -s 本地文件名或本地文件路径

# 使用IPV6请求
curl -6s https://transfer.init.ac/scripts/file.sh|bash -s 本地文件名或本地文件路径
```

例子

```shell
# 本地文件路径
$ cat /etc/centos-release
CentOS Linux release 7.9.2009 (Core)

# 开始传输文件并返回文件链接
$ curl -4s https://transfer.init.ac/scripts/file.sh|bash -s /etc/centos-release
/etc/centos-release transfer success; file url: https://transfer.init.ac/vC3mF3/centos-release

# 测试请求访问文件
$ curl https://transfer.init.ac/vC3mF3/centos-release
CentOS Linux release 7.9.2009 (Core)
```

文件共享控制(可选)

```shell
执行前定义

# 开启控制
export save_file_control=true
# 文件最大保存天数
export max_save_days=1
# 文件最大下载次数
export max_download_nums=1


# 取消控制
unset save_file_control
```
## 2022年09月17日 增加Spug自动注册脚本

使用步骤-创建认证

```shell
-- 新建主机组：自动注册
-- 创建角色：api
-- 功能权限：新建主机
-- 主机权限：自动注册
-- 新建账户：api --> 角色: api
```

使用步骤-执行脚本 

```shell
# 程序仅支持amd64位处理器、Linux系统
# 需可连接运维平台;被控主机需提前配置运维平台ssh公钥（则 运维平台可免密登录到被控主机）

export DEVOPS_URL='https://ops.demo.com/' # 运维平台地址;例如：https://ops.demo.com/
export DEVOPS_USER='api'                  # 运维平台账户;例如：api
export DEVOPS_PASSWD='demo123'            # 运维平台api用户密码;例如：demo123

if [[ -f /tmp/add_host ]];then rm -rf /tmp/add_host ;fi
curl -so /tmp/add_host https://mirrors.itan90.cn/scripts/devops/add_host_20221008
chmod +x /tmp/add_host && /tmp/add_host 被控主机名 被控主机IP 被控主机SSH用户 被控主机SSH端口

# 例如：
# chmod +x /tmp/add_host && /tmp/add_host host_01 192.168.0.1 root 22
```

按照上述操作;执行即可

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
$ curl -s -O https://mirrors.itan90.cn/scripts/other/ip_query && chmod +x ip_query && ./ip_query
# 执行后返回以下信息：
虚拟 IPV4 地址: 114.0.0.0.0
虚拟 IPV6 地址: 240e:388...
真实 IPV4 地址: 114.0.0.0.0
真实 IPV6 地址: 240e:388...
```

## 2021年09月10日 增加V2RAY部署脚本 ⭐

1、安装BBR加速 

```
cd /usr/src && wget -N --no-check-certificate "https://mirrors.itan90.cn/scripts/net/bbr/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
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
cd /usr/src && curl -O https://mirrors.itan90.cn/scripts/net/v2ray/v2ray_ws_tls.sh && chmod +x v2ray_ws_tls.sh && ./v2ray_ws_tls.sh
```


## 2021年07月03日 增加初始化脚本

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
export idc='华为云' ; export region='中国-上海市' ; export app='v2ray'
curl -s "https://mirrors.itan90.cn/scripts/init/main.sh" |bash

# 不执行监控部署
curl -s "https://mirrors.itan90.cn/scripts/init/main_no_monitor.sh" |bash
```


## 2021年07月02日 基础源仓库建立
