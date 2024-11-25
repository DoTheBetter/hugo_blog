---
title: VPS自用Debian系统初始化脚本
date: 2024-11-20T14:46:31+08:00
lastmod: 2024-11-25T23:48:23+08:00
tags:
  - VPS
  - 系统优化
  - docker
  - 脚本
description: 该脚本主要用于一键安装和配置 VPS，主要目的是为了快速搭建一个稳定、安全和高效的 Docker 环境，并通过定期维护保证系统的良好运行状态。
categories:
  - VPS
  - 服务器
collections:
  - VPS系统安装
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

本文适用的系统版本：**Debian 12**

该脚本主要用于一键安装和配置 VPS，主要目的是为了快速搭建一个稳定、安全和高效的 Docker 环境，并通过定期维护保证系统的良好运行状态。内容包括以下几个部分：

1. 系统安全优化：配置 ssh 服务，优化内核参数，设置 ulimit 参数以限制进程数。
2. 时区与语言环境配置：将系统时间与时区同步，并调整 locale 环境变量。
3. 安装最新的 Docker Engine 及其 Compose 工具。
4. 配置脚本和定时任务：
    - 创建并设置了系统的自动更新脚本，每天凌晨 5 点执行一次以确保软件包最新且无冗余依赖。
    - 添加了 ntpdate 命令的定时任务，每 20 分钟同步系统时间。

## 系统更新并安装常用软件包

```shell
apt-get update -y
apt-get upgrade -y
apt-get install -y wget curl apt-transport-https ca-certificates
```

## 时区及时间同步设置

```shell
# 时区设置
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#安装 NTP 同步时间并启用
apt-get install -y ntpdate
ntpdate -u pool.ntp.org
```

## 系统设置

### 配置用户限制/etc/security/limits. conf

```shell
[ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
[ -z "$(grep 'session required pam_limits.so' /etc/pam.d/common-session)" ] && echo "session required pam_limits.so" >> /etc/pam.d/common-session
sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
root soft nproc 1000000
root hard nproc 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF
```

### 配置主机名 /etc/hosts

```shell
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@127.0.0.1.*localhost@&\n127.0.0.1	$(hostname)@g" /etc/hosts
```

### 配置内核参数 /etc/sysctl. conf

```shell
[ -z "$(grep 'net.core.default_qdisc' /etc/sysctl.conf)" ] && cat >> /etc/sysctl.conf << EOF
# 开启 BBR ，网络优化
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_rmem = 8192 262144 536870912
net.ipv4.tcp_wmem = 4096 16384 536870912
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_collapse_max_bytes = 6291456
net.ipv4.tcp_notsent_lowat = 131072
net.ipv4.ip_local_port_range = 1024 65535
net.core.rmem_max = 536870912
net.core.wmem_max = 536870912
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_max_tw_buckets = 65536
net.ipv4.tcp_abort_on_overflow = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_max_syn_backlog = 32768
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 3
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.ip_forward = 1
fs.file-max = 104857600
fs.inotify.max_user_instances = 8192
fs.nr_open = 1048576
EOF
sysctl -p
```

### ipv4 优先于 ipv6

```shell
echo "precedence ::ffff:0:0/96  100" >>/etc/gai.conf
```

## 配置 SSH 服务器

```shell
#随机生成ssh端口
sshport=$(shuf -i 60000-65535 -n 1)
sed -i "s/#Port 22/Port $sshport/g" /etc/ssh/sshd_config
sed -i "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
# 获取 SSH 端口，如果不存在或为空，则使用默认值 22
PORT=$(awk '/^Port / {print $2}' /etc/ssh/sshd_config)
if [ -z "$PORT" ]; then
    PORT=22
    echo "WARNING: No 'Port' setting in /etc/ssh/sshd_config, using default port 22."
fi
echo "SSH Server Port: $PORT"

cat >> /etc/ssh/sshd_config << EOF
PermitRootLogin yes
PubkeyAuthentication yes

TCPKeepAlive yes
ClientAliveInterval 120 
ClientAliveCountMax 30
EOF

# 重启SSH服务
systemctl restart sshd
```

## 安装 UFW 防火墙

```shell
apt-get install -y ufw
#检查下 UFW 是否已经在运行,inactive , 意思是没有被激活或不起作用。
ufw status
#启用
echo "y" | ufw enable
#添加规则
# 禁止所有入流量
ufw default deny incoming
# 允许所有出流量
ufw default allow outgoing
ufw allow $PORT/tcp
ufw allow 80
ufw allow 443
ufw allow 100
```

## 一键安装最新版 Docker Engine

```shell
#https://docs.docker.com/engine/install/debian/
#卸载预装的非官方 Docker 软件包
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove -y $pkg; done
#使用阿里源安装，使用中国区Azure源安装 --mirror AzureChinaCloud
curl -fsSL https://raw.githubusercontent.com/docker/docker-install/master/install.sh -o get-docker.sh
sh get-docker.sh --mirror Aliyun

#解决WARNING: bridge-nf-call-iptables is disabled
#临时加载 br_netfilte
modprobe br_netfilter
#启动时运行此模块
cat >> /etc/modules-load.d/modules.conf << EOF
br_netfilter
EOF

#docker 配置
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
      "https://docker.fxxk.dedyn.io",
      "https://hub.geekery.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
      "max-size": "10m",
      "max-file": "3"
  }
}

EOF
#重新启动 Docker 服务使配置生效
systemctl daemon-reload
systemctl restart docker
```

## 一键安装最新版 Docker Compose

```shell
#https://docs.docker.com/compose/install/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

## 删除不必要的包和临时文件

```shell
apt-get --purge remove -y
apt-get clean
```

## 显示脚本运行结果

```shell
echo "=============Installation status============="
echo `date "+%Y-%m-%d %H:%M:%S"`
echo "sshport：【$PORT】"
#列出当前UFW规则
ufw status verbose
#显示版本
docker info
docker-compose --version
echo "=============Installation status============="
```

## 生成计划任务

### 系统定时更新脚本

```shell
cat > /root/update_system.sh << EOF
#!/bin/bash

# 更新软件包列表
apt-get update
# 升级所有已安装的软件包
apt-get upgrade -y
# 清理未使用的依赖
apt-get --purge remove -y
# 自动删除旧内核（如果有新内核可用）
apt-get clean
# 检查是否需要重新启动
echo 'Checking for reboot requirement at \$(date)'
if [ -f /var/run/reboot-required ]; then
  # 如果找到 /var/run/reboot-required 文件，则执行以下命令
  echo "Reboot required. Initiating reboot…"
  reboot
else
  echo "No reboot required."
fi

EOF
chmod +x /root/update_system.sh
```

### 添加定时任务到 crontab 文件

```shell
# 检查并添加 update_system.sh 定时任务到 root 的 crontab 文件
if ! grep -q "update_system.sh" /var/spool/cron/crontabs/root 2>/dev/null; then
    echo "0 5 * * * /root/update_system.sh > /root/update_system.log 2>&1" >> /var/spool/cron/crontabs/root   
fi

# 检查并添加 ntpdate 定时任务到 root 的 crontab 文件
if [ -z "$(grep ntpdate /var/spool/cron/crontabs/root 2>/dev/null)" ]; then
    echo "*/20 * * * * $(which ntpdate) -u pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
fi

chmod 600 /var/spool/cron/crontabs/root
```

## 完成后重启 vps

```shell
echo "本次脚本运行涉及以下文件更改，请确认正确后重启："
echo "/etc/security/limits.conf"
echo "/etc/hosts"
echo "/etc/sysctl.conf"
echo "/etc/gai.conf"
echo "/etc/ssh/sshd_config"
echo "/var/spool/cron/crontabs/root"

read -p "请检查所有配置是否正确，是否需要手动重启 (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    reboot
else
    echo "你可以稍后手动执行 'reboot' 命令来重启系统。"
fi
```

## 完整脚本代码

完整代码加入了运行权限，标题输出高亮及 github 代理的设置

```shell {data-open=false}
#!/bin/bash
#执行nano install.sh , 复制粘贴下列信息后，Ctrl-X 退出并保存
#chmod +x install.sh | bash install.sh

# 检查是否以root用户或sudo权限运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "请以root用户或sudo权限执行此脚本!"
    exit 1
fi

# 创建一个函数来输出带有蓝色背景的信息
Echo_Blue() {
    echo -e "\033[36m$1\033[0m"
}

#github加速节点设置
github_proxy="https://ghp.miaostay.com"

####################################################################
# 系统更新
Echo_Blue "系统升级..."
apt-get update -y
apt-get upgrade -y

####################################################################
# 安装常用软件包
Echo_Blue "安装常用软件..."
apt-get install -y wget curl apt-transport-https ca-certificates

####################################################################
# 时区及时间同步设置
Echo_Blue "设置时区..."
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

####################################################################
#安装 NTP 同步时间并启用
Echo_Blue "[+] 安装并同步NTP服务..."
apt-get install -y ntpdate
ntpdate -u pool.ntp.org

####################################################################
#系统设置
#配置用户限制/etc/security/limits.conf
[ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
[ -z "$(grep 'session required pam_limits.so' /etc/pam.d/common-session)" ] && echo "session required pam_limits.so" >> /etc/pam.d/common-session
sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
root soft nproc 1000000
root hard nproc 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF

#配置主机名 /etc/hosts
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@127.0.0.1.*localhost@&\n127.0.0.1	$(hostname)@g" /etc/hosts

#配置内核参数 /etc/sysctl.conf
# 开启 BBR ，网络优化
[ -z "$(grep 'net.core.default_qdisc' /etc/sysctl.conf)" ] && cat >> /etc/sysctl.conf << EOF
# 开启 BBR ，网络优化
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_rmem = 8192 262144 536870912
net.ipv4.tcp_wmem = 4096 16384 536870912
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_collapse_max_bytes = 6291456
net.ipv4.tcp_notsent_lowat = 131072
net.ipv4.ip_local_port_range = 1024 65535
net.core.rmem_max = 536870912
net.core.wmem_max = 536870912
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_max_tw_buckets = 65536
net.ipv4.tcp_abort_on_overflow = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_max_syn_backlog = 32768
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 3
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.ip_forward = 1
fs.file-max = 104857600
fs.inotify.max_user_instances = 8192
fs.nr_open = 1048576
EOF
sysctl -p

# ipv4 优先于 ipv6
echo "precedence ::ffff:0:0/96  100" >>/etc/gai.conf

####################################################################
#配置 SSH 服务器
Echo_Blue "SSH config..."
sshport=$(shuf -i 60000-65535 -n 1)
sed -i "s/#Port 22/Port $sshport/g" /etc/ssh/sshd_config
sed -i "s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
# 获取 SSH 端口，如果不存在或为空，则使用默认值 22
PORT=$(awk '/^Port / {print $2}' /etc/ssh/sshd_config)
if [ -z "$PORT" ]; then
    PORT=22
    Echo_Blue "WARNING: No 'Port' setting in /etc/ssh/sshd_config, using default port 22."
fi
Echo_Blue "SSH Server Port: $PORT"

cat >> /etc/ssh/sshd_config << EOF
PermitRootLogin yes
PubkeyAuthentication yes

TCPKeepAlive yes
ClientAliveInterval 120 
ClientAliveCountMax 30
EOF

# 重启SSH服务
systemctl restart sshd

####################################################################
#安装防火墙
Echo_Blue "[+] 安装ufw..."
apt-get install -y ufw
#检查下 UFW 是否已经在运行,inactive , 意思是没有被激活或不起作用。
ufw status
#启用
echo "y" | ufw enable
#添加规则
# 禁止所有入流量
ufw default deny incoming
# 允许所有出流量
ufw default allow outgoing
ufw allow $PORT/tcp
ufw allow 80
ufw allow 443
ufw allow 100

####################################################################
# 一键安装最新版Docker Engine 
#https://docs.docker.com/engine/install/debian/
Echo_Blue "[+] 安装Docker Engine ..."
#卸载预装的非官方 Docker 软件包
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove -y $pkg; done
#使用阿里源安装，使用中国区Azure源安装 --mirror AzureChinaCloud
curl -fsSL $github_proxy/https://raw.githubusercontent.com/docker/docker-install/master/install.sh -o get-docker.sh
sh get-docker.sh --mirror Aliyun

#解决WARNING: bridge-nf-call-iptables is disabled
#临时加载 br_netfilte
modprobe br_netfilter
#启动时运行此模块
cat >> /etc/modules-load.d/modules.conf << EOF
br_netfilter
EOF

#docker 设置
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
      "https://docker.fxxk.dedyn.io",
      "https://hub.geekery.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
      "max-size": "10m",
      "max-file": "3"
  }
}

EOF
#重新启动 Docker 服务
systemctl daemon-reload
systemctl restart docker

####################################################################
#一键安装最新版Docker Compose
#https://docs.docker.com/compose/install/
Echo_Blue "[+] 安装Docker-compose..."
curl -SL $github_proxy/https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

####################################################################
# 删除不必要的包和临时文件
Echo_Blue "删除不必要的包和临时文件..."
apt-get --purge remove -y
apt-get clean

Echo_Blue "=============Installation status============="
echo `date "+%Y-%m-%d %H:%M:%S"`
echo "sshport：【$PORT】"
#列出当前UFW规则
ufw status verbose
#显示版本
docker info
docker-compose --version
Echo_Blue "=============Installation status============="

####################################################################
#生成计划任务
cat > /root/update_system.sh << EOF
#!/bin/bash

# 更新软件包列表
apt-get update
# 升级所有已安装的软件包
apt-get upgrade -y
# 清理未使用的依赖
apt-get --purge remove -y
# 自动删除旧内核（如果有新内核可用）
apt-get clean
# 检查是否需要重新启动
echo 'Checking for reboot requirement at \$(date)'
if [ -f /var/run/reboot-required ]; then
  # 如果找到 /var/run/reboot-required 文件，则执行以下命令
  echo "Reboot required. Initiating reboot..."
  reboot
else
  echo "No reboot required."
fi

EOF
chmod +x /root/update_system.sh

# 检查并添加 update_system.sh 定时任务到 root 的 crontab 文件
if ! grep -q "update_system.sh" /var/spool/cron/crontabs/root 2>/dev/null; then
    echo "0 5 * * * /root/update_system.sh > /root/update_system.log 2>&1" >> /var/spool/cron/crontabs/root   
fi

# 检查并添加 ntpdate 定时任务到 root 的 crontab 文件
if [ -z "$(grep ntpdate /var/spool/cron/crontabs/root 2>/dev/null)" ]; then
    echo "*/20 * * * * $(which ntpdate) -u pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/crontabs/root
fi

chmod 600 /var/spool/cron/crontabs/root

####################################################################
# 提示用户是否手动重启
echo "本次脚本运行涉及以下文件更改，请确认正确后重启："
Echo_Blue "/etc/security/limits.conf"
Echo_Blue "/etc/hosts"
Echo_Blue "/etc/sysctl.conf"
Echo_Blue "/etc/gai.conf"
Echo_Blue "/etc/ssh/sshd_config"
Echo_Blue "/var/spool/cron/crontabs/root"

read -p "请检查所有配置是否正确，是否需要手动重启 (y/n): " choice
if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    reboot
else
    echo "你可以稍后手动执行 'reboot' 命令来重启系统。"
fi
```
