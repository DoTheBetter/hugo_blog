---
title: 在 Proxmox VE 环境下自动部署最新版 RouterOS CHR
date: 2024-12-28T20:13:06+08:00
lastmod: 2024-12-29T20:38:38+08:00
tags:
  - ProxmoxVE
  - 虚拟机
  - 脚本
  - RouterOS
description: 这篇文章详细介绍了在Proxmox VE环境中使用脚本自动安装和配置最新稳定RouterOS (ROS) Chrome OS版本的步骤，并提供了相关脚本代码。
categories:
  - PVE
  - 服务器
collections: 
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

‌‌‌‌　　近年来，在 Proxmox VE 平台上搭建家庭小主机成为了越来越多人的选择。很多用户倾向于在该平台上安装 RouterOS（CHR），以实现软路由解决方案。然而，对于那些希望节省成本并称之为 " 白嫖党 " 的用户来说，每次手动更新安装新版的 RouterOS（CHR）确实是一种繁琐的过程。  
‌‌‌‌　　鉴于此，我在 Mikrotik 官方发布的用于 Proxmox VE 下的 CHR 安装脚本 [CHR ProxMox 安装指南](https://help.mikrotik.com/docs/display/ROS/CHR+ProxMox+installation) 的基础上做了一些调整与增强，新增功能包括自动获取最新版本和提供扩展磁盘容量的支持。通过严格遵循本文中的步骤操作，你将能够快速构建并运行最新的 RouterOS (CHR) 环境于虚拟机中。  
‌‌‌‌　　这些改进旨在简化更新过程，并提升用户的使用体验。无论你是技术新秀还是资深玩家，都能在本文的指导下顺利完成操作。  

## 1. 安装准备

在开始之前，请确保你的 Proxmox VE 环境已经安装好，且满足以下条件：
1. 执行脚本前需要确保：
    + 已配置好 Proxmox VE 环境
    + 具有 root 权限
    + 系统已安装 unzip 工具
2. 虚拟机 ID 选择：
    + 需要选择未被使用的 ID
    + 建议使用 101 以上的数字

## 2. 脚本主要功能

脚本简化了在 Proxmox VE 环境中部署 RouterOS CHR 的流程，它将自动完成以下步骤：
1. 自动获取最新版本
	+ 从 MikroTik 官方 RSS 源获取最新稳定版 RouterOS 下载链接
	+ 自动解析版本号，也支持手动指定版本号
2. 映像文件处理
	+ 下载最新稳定版或指定版本的 CHR 映像文件
	+ 将原始 raw 格式转换为 qcow2 格式
	+ 自动扩展磁盘容量（默认增加 1GB）
3. 虚拟机配置
	+ 自动创建虚拟机目录结构
	+ 配置基本虚拟机参数

## 3. 脚本运行  

### 3.1. 完整代码  

```shell
#!/bin/bash
#官方脚本 https://help.mikrotik.com/docs/display/ROS/CHR+ProxMox+installation
#执行nano pve_install_ros.sh , 复制粘贴下列信息后，Ctrl-X 退出并保存
#chmod +x pve_install_ros.sh | bash pve_install_ros.sh

# 检查是否安装了unzip，如果没有则安装
if ! command -v unzip &> /dev/null
then
    echo "未找到unzip，正在安装..."
    apt-get update
    apt-get install unzip -y
fi

echo "############## 开始脚本 ##############"

#获取最新RouterOS稳定版下载地址
download_link=$(curl -s https://download.mikrotik.com/routeros/latest-stable.rss | \
    awk '/<item>/{p=1;next} p&&/<link>/{gsub(/^[ \t]+/,"");print;exit}' | \
    sed 's/<link>\(.*\)<\/link>/\1/')
echo "最新RouterOS稳定版下载链接: $download_link"

#获取RouterOS新版版本号
last_version=$(echo "$download_link" | sed -n 's/.*v=\([0-9.]*\).*/\1/p')
echo "最新RouterOS稳定版版本: $last_version"

## 检查TEMP目录是否可用..."
if [ -d /root/temp ]
then
    echo "-- TEMP下载目录已存在！"
else
    echo "-- 建立TEMP下载目录！"
    mkdir /root/temp
fi

echo "## 准备ROS_CHR image文件下载和VM虚拟机创建！"
# 询问用户版本，默认使用新版本号
version=$last_version
read -p "是否下载最新版本RouterOS Chr？ (Y=最新版/n=指定版本): " confirm
if [[ ${confirm,,} == "n" ]]; then
    read -p "请输入Chr版本以部署（6.38.2,6.40.1等）： " user_version
    version=$user_version
fi
echo "选择的RouterOS Chr版本为: $version"

# 检查image文件是否需要下载
if [ -f /root/temp/chr-$version.img ]
then
    echo "-- CHR $version image文件已存在."
else
    echo "-- 下载CHR $version image文件."
    cd /root/temp
    echo "---------------------------------------------------------------------------"
    wget https://download.mikrotik.com/routeros/$version/chr-$version.img.zip
    unzip chr-$version.img.zip
    echo "---------------------------------------------------------------------------"
fi

# 列出已存在的VM虚拟机
vmID="nil"
echo "== 列出已存在的VM虚拟机列表！"
qm list
echo ""
read -p "请输入未使用的VM ID（例如：101）：" vmID
echo ""

# 为VM创建存储目录。
if [ -d /var/lib/vz/images/$vmID ]
then
    echo "-- VM虚拟机文件夹已存在！请更换VM ID！"
    read -p "请输入未使用的VM ID（例如：101）：" vmID
else
    echo "-- 建立VM虚拟机文件夹! "
    mkdir /var/lib/vz/images/$vmID
fi

# 转换映像重命名
echo "-- 将image转换为qcow2格式 "
qemu-img convert \
    -f raw \
    -O qcow2 \
    /root/temp/chr-$version.img \
    /var/lib/vz/images/$vmID/vm-$vmID-disk-1.qcow2

echo "-- 增加加映像容量"
# 增加映像大小 根据自己使用调整
qemu-img resize -f qcow2 /var/lib/vz/images/$vmID/vm-$vmID-disk-1.qcow2 +1G

echo "-- 查看映像信息"
# 查看映像信息
qemu-img info /var/lib/vz/images/$vmID/vm-$vmID-disk-1.qcow2

# 建立虚拟机
echo "-- 建立新的CHR虚拟机"
qm create $vmID \
  --name ROS-chr-$version \
  --net0 virtio,bridge=vmbr0 \
  --bootdisk virtio0 \
  --ostype l26 \
  --memory 512 \
  --onboot no \
  --sockets 1 \
  --cores 2 \
  --virtio0 local:$vmID/vm-$vmID-disk-1.qcow2

# 检查虚拟机是否建立成功
if [ $? -eq 0 ]; then
    echo "虚拟机创建成功！"
else
    echo "虚拟机创建失败！请检查设置并手动进行调整。"
fi

echo "############## 脚本结束 ##############"
```
将以上脚本代码保存为 `pve_install_ros.sh` 放到 Proxmox VE 主机上，建议存放在 `/root/` 目录下。

### 3.2. 执行脚本  

```shell
chmod +x pve_install_ros.sh | bash pve_install_ros.sh
```
‌‌‌‌您将被提示选择是否使用新版本 RouterOS 或指定特定的版本号， 按照屏幕上的说明进行操作完成脚本配置。  

### 3.3. 查看虚拟机

成功执行脚本后，你可以查看 Proxmox VE 管理界面中的虚拟机列表，找到新建的 CHR 虚拟机。

## 4. 虚拟机配置说明  

`qm create` 是 PVE 中创建虚拟机的基本命令，`$vmID` 是虚拟机的唯一标识符。  
主要配置参数说明：
+ `--name ROS-chr-$version`: 设置虚拟机的名称，其中 `$version` 是一个变量，表示系统版本
+ `--net0 virtio,bridge=vmbr0`: 配置网络接口，使用 virtio 驱动，连接到 vmbr0 网桥。**提示: 只配置了一个 `lan` 网口，可自行在虚拟机管理界面添加 `wan` 口。**
+ `--bootdisk virtio0`: 指定启动磁盘为 virtio0
+ `--ostype l26`: 设置操作系统类型为 Linux 2.6/3-6. x kernel
+ `--memory 512`: 分配 512MB 内存
+ `--onboot no`: 设置虚拟机在 PVE 主机启动时不自动启动
+ `--sockets 1`: 配置 1 个 CPU 插槽
+ `--cores 2`: 每个 CPU 插槽配置 2 个核心
+ `--virtio0`: 指定虚拟磁盘存储位置，使用本地存储，路径为 `local:$vmID/vm-$vmID-disk-1.qcow2`

‌‌‌‌　　这个命令会创建一个相对轻量级的虚拟机，用于运行 RouterOS (ROS) ChromeOS 版本的配置。使用 virtio 驱动可以提供更好的性能，而 qcow2 格式的磁盘支持动态分配空间。
