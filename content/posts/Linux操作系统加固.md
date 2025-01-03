---
title: Linux操作系统加固
date: 2024-11-26T12:07:17+08:00
lastmod: 2024-12-08T19:57:52+08:00
tags:
  - Linux
  - 系统加固
  - VPS
  - 服务器安全
  - 阿里云
description: 文章详细介绍了如何通过账号管理和服务配置等措施来加固Linux操作系统，提高系统的安全性。主要内容包括禁用或删除无用账号、检查特殊账号、添加口令策略、限制用户 su 权限、禁止 root 用户直接登录、关闭不必要的服务、SSH 服务安全设置、设置 umask 值、设置登录超时时间以及启用日志功能等。
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

以下是来着 [阿里云帮助中心](https://help.aliyun.com/document_detail/49809.html) 的帮助手册

## 1. 账号和口令

### 1.1. 禁用或删除无用账号

减少系统无用账号，降低安全风险。

**操作步骤**
+ 使用命令 `userdel <用户名>` 删除不必要的账号。
+ 使用命令 `passwd -l <用户名>` 锁定不必要的账号。
+ 使用命令 `passwd -u <用户名>` 解锁必要的账号。

### 1.2. 检查特殊账号

检查是否存在空口令和 root 权限的账号。

**操作步骤**

1. 查看空口令和 root 权限账号，确认是否存在异常账号：
    + 使用命令 `awk -F: '($2=="")' /etc/shadow` 查看空口令账号。
    + 使用命令 `awk -F: '($3==0)' /etc/passwd` 查看 UID 为零的账号。

2. 加固空口令账号：
    + 使用命令 `passwd <用户名>` 为空口令账号设定密码。
    + 确认 UID 为零的账号只有 root 账号。

### 1.3. 添加口令策略

加强口令的复杂度等，降低被猜解的可能性。

**操作步骤**

1. 使用命令 `vi /etc/login.defs` 修改配置文件。
    + `PASS_MAX_DAYS 90 #新建用户的密码最长使用天数`
    + `PASS_MIN_DAYS 0 #新建用户的密码最短使用天数`
    + `PASS_WARN_AGE 7 #新建用户的密码到期提前提醒天数`

2. 使用 chage 命令修改用户设置。  
    例如，`chage -m 0 -M 30 -E 2000-01-01 -W 7 <用户名>` 表示将此用户的密码最长使用天数设为 30，最短使用天数设为 0，密码 2000 年 1 月 1 日过期，过期前七天警告用户。

3. 设置连续输错三次密码，账号锁定五分钟。使用命令 `vi /etc/pam.d/common-auth` 修改配置文件，在配置文件中添加 `auth required pam_tally.so onerr=fail deny=3 unlock_time=300`。

### 1.4. 限制用户 su

限制能 su 到 root 的用户。

**操作步骤**

使用命令 `vi /etc/pam.d/su` 修改配置文件，在配置文件中添加行。例如，只允许 test 组用户 su 到 root，则添加 `auth required pam_wheel.so group=test`。

### 1.5. 禁止 root 用户直接登录

限制 root 用户直接登录。

**操作步骤**
1. 创建普通权限账号并配置密码,防止无法远程登录;
2. 使用命令 `vi /etc/ssh/sshd_config` 修改配置文件将 PermitRootLogin 的值改成 no，并保存，然后使用 `service sshd restart` 重启服务。

## 2. 服务

### 2.1. 关闭不必要的服务

关闭不必要的服务（如普通服务和 xinetd 服务），降低风险。

**操作步骤**

使用命令 `systemctl disable <服务名>` 设置服务在开机时不自动启动。

**说明**： 对于部分老版本的 Linux 操作系统（如 CentOS 6），可以使用命令 `chkconfig --level <init级别> <服务名> off` 设置服务在指定 init 级别下开机时不自动启动。

### 2.2. SSH 服务安全

对 SSH 服务进行安全加固，防止暴力破解成功。

**操作步骤**

使用命令 `vim /etc/ssh/sshd_config` 编辑配置文件。

+ 不允许 root 账号直接登录系统。  
    设置 PermitRootLogin 的值为 no。

+ 修改 SSH 使用的协议版本。  
    设置 Protocol 的版本为 2。

+ 修改允许密码错误次数（默认 6 次）。  
    设置 MaxAuthTries 的值为 3。

配置文件修改完成后，重启 sshd 服务生效。

## 3. 文件系统

### 3.1. 设置 umask 值

设置默认的 umask 值，增强安全性。

**操作步骤**

使用命令 `vi /etc/profile` 修改配置文件，添加行 `umask 027`， 即新创建的文件属主拥有读写执行权限，同组用户拥有读和执行权限，其他用户无权限。

### 3.2. 设置登录超时

设置系统登录后，连接超时时间，增强安全性。

**操作步骤**

使用命令 `vi /etc/profile` 修改配置文件，将以 `TMOUT=` 开头的行注释，设置为 `TMOUT=180`，即超时时间为三分钟。

## 4. 日志

### 4.1. syslogd 日志

启用日志功能，并配置日志记录。

**操作步骤**

Linux 系统默认启用以下类型日志：
+ 系统日志（默认）/var/log/messages
+ cron 日志（默认）/var/log/cron
+ 安全日志（默认）/var/log/secure

**注意**：部分系统可能使用 syslog-ng 日志，配置文件为：/etc/syslog-ng/syslog-ng.conf。

您可以根据需求配置详细日志。

### 4.2. 记录所有用户的登录和操作日志

通过脚本代码实现记录所有用户的登录操作日志，防止出现安全事件后无据可查。

**操作步骤**

1. 运行 `[root@xxx /]# vim /etc/profile` 打开配置文件。
2. 在配置文件中输入以下内容：

    ```bash
     history
     USER=`whoami`
     USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
     if [ "$USER_IP" = "" ]; then
     USER_IP=`hostname`
     fi
     if [ ! -d /var/log/history ]; then
     mkdir /var/log/history
     chmod 777 /var/log/history
     fi
     if [ ! -d /var/log/history/${LOGNAME} ]; then
     mkdir /var/log/history/${LOGNAME}
     chmod 300 /var/log/history/${LOGNAME}
     fi
     export HISTSIZE=4096
     DT=`date +"%Y%m%d_%H:%M:%S"`
     export HISTFILE="/var/log/history/${LOGNAME}/${USER}@${USER_IP}_$DT"
     chmod 600 /var/log/history/${LOGNAME}/*history* 2>/dev/null
    ```

3. 运行 `[root@xxx /]# source /etc/profile` 加载配置生效。

    **注意**： /var/log/history 是记录日志的存放位置，可以自定义。

通过上述步骤，可以在 /var/log/history 目录下以每个用户为名新建一个文件夹，每次用户退出后都会产生以用户名、登录 IP、时间的日志文件，包含此用户本次的所有操作（root 用户除外）。
