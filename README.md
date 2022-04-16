> `最后更新人：admin`
>
> `最后更新日期：2021年12月28日`

## ~~(已作废) 2021年12月28日 增加每天60秒~~

```
调用方法：GET
API地址：http://mirrors.itan90.cn/60s/news.jpg
```

## 2021年12月19日 增加远程下载工具 ⭐

1、安装Docker

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

## 2021年10月04日 新增Python镜像源 ⭐

优点：国内自建Python mirrors镜像源；提高安装模块速度

注意：默认3141端口不对外开放；需联系邮箱 `admin@bohai.email`开放访问

```
[root@node ~]# mkdir ~/.pip
[root@node ~]# vim ~/.pip/pip.conf
[global]
timeout = 60
index-url = http://mirrors.itan90.cn:3141/root/pypi/+simple/

[install]
trusted-host = mirrors.itan90.cn

[root@node ~]# pip install requests
```

## 2021年10月01日 支持IPV6访问请求 ⭐

支持IPV6发起请求尝试访问,但禁止Ping

```
root@srv12776:~# ping -6 mirrors.itan90.cn
PING mirrors.itan90.cn(2407:c080:801:fffe::7925:aa6a (2407:c080:801:fffe::7925:aa6a)) 56 data bytes

```

## 2021年10月01日 新增部署WARP支持

```
参考: https://itan90.cn/archives/49/
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

EUserv IPV6 LXC架构服务器 暂未支持 但有计划编写

```
# EUserv IPV6 LXC架构 专用脚本

```

## 2021年09月29日 新增IP查询脚本 ⭐

```
$ curl -s -O http://mirrors.itan90.cn/scripts/ip_query && chmod +x ip_query && ./ip_query
# 执行后返回以下信息：
虚拟 IPV4 地址: 114.0.0.0.0
虚拟 IPV6 地址: 240e:388...
真实 IPV4 地址: 114.0.0.0.0
真实 IPV6 地址: 240e:388...
```

## 2021年09月10日 新增部署V2RAY脚本 ⭐

*安装BBR加速，会让您的科学上网速度提升很多。*

```
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/bbr/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```

*在弹出的界面选1，安装内核，安装完之后vps会重启，SSH会断开连接，重启等待1到2分钟，重新连接vps ssh，输入以下代码，在弹出的界面输入5，使用BBR。*

```
cd /usr/src && ./tcp.sh
```

V2Ray安装脚本：

```
cd /usr/src && curl -O http://mirrors.itan90.cn/v2ray/v2ray_ws_tls.sh && chmod +x v2ray_ws_tls.sh && ./v2ray_ws_tls.sh
```

*选择：1，回车，因为脚本需要安装Nginx，比较慢，大概五六分钟，等待一下。过程中会提示需要输入域名，输入解析到本VPS的域名，然后回车。* *漫长等待之后，会出现安装完成的信息，您需要注意的是，会有配置参数反馈到您的终端，需要记下来*

## 2021年08月23日 增加监控探针安装 ⭐

---

监控探针版本：5.0.2

监控服务端口：10050

监控服务地址：node.connect.itan90.cn (默认)

监控组件配置：<http://mirrors.itan90.cn/monitor/monitor.d/>

---

更新笔记：

2021年10月3日 增加进程自动发现监控配置（自动化配置 无需人工参与）

2021年10月5日 增加统一Crond管理探针配置（自动化配置 无需人工参与）

2021年10月26日 增加ssh暴力破解监控配置（自动化配置 无需人工参与）

```
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/monitor/Install.sh" && chmod +x Install.sh && ./Install.sh

# 使用主动模式脚本
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/monitor/Install_Active.sh" && chmod +x Install_Active.sh && ./Install_Active.sh

# 使用其他服务地址
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/monitor/Install.sh" && chmod +x Install.sh && ./Install.sh 你的服务端地址
```

## 2021年07月03日 增加服务器初始化脚本

---

初始化脚本版本：1.0.1

初始化脚本备注：推荐在主机安装时通过Base64传入主机内自动化执行脚本

---

2022年1月7日 更新笔记：

基础环境：进程监控、SSH监控、主机监控、DOCKER、DOCKER COMPOSE

应用程序：Remote Download（8999端口）

```
#!/bin/bash
cd /usr/src && wget -N --no-check-certificate "http://mirrors.itan90.cn/scripts/init/main.sh" && chmod +x main.sh && ./main.sh
```

## 2021年07月02日 mirrors 信息发布建立