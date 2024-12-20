---
title: 轻松入门！一步步教你在Proxmox VE中进行磁盘镜像上传及相关配置
date: 2024-12-20T11:50:00+08:00
lastmod: 2024-12-20T14:23:16+08:00
tags:
  - ProxmoxVE
  - 磁盘镜像
description: 这篇文章详细介绍了如何在 Proxmox VE 中上传和导入磁盘镜像。它首先介绍了两种上传方法：通过 Web 界面和 SFTP，并指出每个方法的适用场景。然后，文章讲解了如何使用命令行工具 `qm disk import` 和 `qm importovf` 将镜像文件导入到虚拟机中，并提供了详细的命令示例。最后，文章指导用户在虚拟机配置中添加导入的硬盘，调整引导顺序，并启动虚拟机。
categories:
  - PVE
  - 服务器
collections: 
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

‌‌‌‌　　这篇指南将带你了解如何在 Proxmox VE 中上传和导入磁盘镜像， 为你的虚拟机增添新的存储空间。

## 1. 磁盘镜像上传到 Proxmox VE  

### 1.1. 通过 PVE 的 WEB 界面上传

‌‌‌‌　　Proxmox VE 的 Web 界面提供了简洁的方法上传磁盘镜像。不过请注意，这种方式仅仅支持 **ISO 和 IMG 格式** 的镜像文件。  
![Upload Image](attachments/16bf0d3cc022b4637207626d0979aa59_MD5.jpg)  

‌‌‌‌　　上传后的 ISO 或 IMG 文件默认会被存放在 `/var/lib/vz/template/iso/` 目录下，加上文件名和后缀，就能构建完整的文件路径。 在上传任务日志界面中也可以查看文件路径。  
![Upload Logs](attachments/bf4a08066411036322547153812b391a_MD5.jpg)

### 1.2. 通过 SFTP 上传  

‌‌‌‌　　如果你喜欢使用 SFTP 软件，可以选择通过它连接到 Proxmox VE 服务器，并将镜像文件上传至任意目录。 但需要注意的是，如果上传的是 `.img.gz` 等压缩格式的文件，需要先解压操作，例如 `gzip -d openwrt.img.gz`。

## 2. 导入虚拟机

‌‌‌‌　　将磁盘镜像上传到 Proxmox VE 后，就可以使用命令将它导入到具体的虚拟机中了。  
有关官方命令的使用说明，可以参考 [https://pve.proxmox.com/pve-docs/qm.1.html](https://pve.proxmox.com/pve-docs/qm.1.html) 。你需要确保该镜像格式被 [qemu-img](https://qemu-project.gitlab.io/qemu/tools/qemu-img.html) 支持：
```shell
root@pve:~# qemu-img -h|grep "Supported formats"
Supported formats: alloc-track backup-dump-drive blkdebug blklogwrites blkverify bochs cloop compress copy-before-write copy-on-read dmg file ftp ftps gluster host_cdrom host_device http https iscsi iser luks nbd null-aio null-co nvme parallels pbs preallocate qcow qcow2 qed quorum raw rbd replication snapshot-access throttle vdi vhdx vmdk vpc vvfat zeroinit
```

### 2.1. 命令介绍：qm disk import

这个命令能将外部磁盘映像作为 VM 中未使用的磁盘导入，其用法如下：
```shell
qm disk import <vmid> <source> <storage> [OPTIONS]
简化用法：qm importdisk

说明：
  <vmid>: 已存在的虚拟机（唯一）ID，(100 - 999999999)范围内的整数
  <source>: 要导入的磁盘映像的路径
  <storage>: 存储磁盘镜像的位置，如local-lvm或者local
  [OPTIONS]：可选用参数
    --format <qcow2 | raw | vmdk>  磁盘镜像格式
    --target-disk <efidisk0 | ide0 | ide1 | sata0 | sata1 | scsi0 | scsi1 |......>将卷导入到的磁盘名称
```

### 2.2. 命令介绍：qm importovf

这个命令用来导入 ovf 格式的磁盘镜像：
```shell
qm importovf <vmid> <manifest> <storage> [OPTIONS]

说明：
  <vmid>: 已存在的虚拟机（唯一）ID，(100 - 999999999)范围内的整数
  <manifest>: 要导入的ovf文件路径
  <storage>: 存储磁盘镜像的位置，如local-lvm或者local
  [OPTIONS]：可选用参数
    --dryrun <true | false> 显示执行过程，但不创建
    --format <qcow2 | raw | vmdk> 磁盘镜像格式
```

### 2.3. 导入操作

#### 2.3.1. 导入 img 文件

```shell
qm disk import 100 /tmp/openwrt-x86-64-generic-squashfs-uefi.img local-lvm --format qcow2
```

#### 2.3.2. 导入 ovf 文件

```shell
qm importovf 100 ./MikroTik-RouterOS-6.40.3.ovf local-lvm --format qcow2
```

#### 2.3.3. 导入 voa 文件

```shell
#voa先解压，拿到ovf文件，按照ovf的方式导入
tar xvf ROS6.40.4.ova
ls
MikroTik-RouterOS-6.40.3.ovf
MikroTik-RouterOS-6.40.3.mf
MikroTik-RouterOS-6.40.3-disk1.vmdk
MikroTik-RouterOS-6.40.3-disk2.vmdk
```

#### 2.3.4. 导入 vmdk 文件

```shell
qm disk import 100 /tmp/chr-6.36.vmdk local-lvm --format raw
```

### 2.4. 添加导入硬盘

‌‌‌‌　　导入虚拟机后，编辑虚拟机的配置，点击 `硬件`。你在里面会看到一个未使用的磁盘，选择它并双击。  
![Add Disk](attachments/01a88263006c51a765cf6c3949e5b6c7_MD5.jpg)

一般情况下，默认设置即可，最后点击 `添加` 确认操作。  
![Confirm Add](attachments/96222df8a5298b9eb12c800a0dc284c0_MD5.jpg)

### 2.5. 调整引导顺序  

‌‌‌‌　　最后一步是调整虚拟机引导顺序。在虚拟机的 `选项` → `引导顺序` 中，选择刚才添加的硬盘并勾选它， 取消其他勾选项，点击 `确定` 并保存更改。

![Boot Order](attachments/2526c3fd0ecfbefe29ac0c7b7b181bcc_MD5.jpg)

![Boot Order](attachments/3b1eea130dc99f368317d1e22d0e5117_MD5.jpg)

最后完成其他调整设置就可以启动虚拟机了。  
