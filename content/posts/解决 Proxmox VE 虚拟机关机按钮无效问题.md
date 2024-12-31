---
title: 解决 Proxmox VE 虚拟机关机按钮无效问题
date: 2024-12-23T14:45:39+08:00
lastmod: 2024-12-31T20:38:12+08:00
tags:
  - ProxmoxVE
  - 虚拟机
description: 文章介绍了在Proxmox VE中解决虚拟机关机按钮无效问题的方法：当未安装acpid服务时，虚拟机会无法正确响应关机信号，通过进入系统Shell并使用`qm stop`命令可以强制关闭虚拟机，但这种方法可能会导致数据损坏。文章还详细解释了如何使用该命令及其参数。
categories:
  - PVE
  - 服务器
collections: 
featuredImage: https://www.bing.com/th?id=OHR.MouseholeXmas_ZH-CN3079184443_400x240.jpg
featuredImagePreview: https://www.bing.com/th?id=OHR.MouseholeXmas_ZH-CN3079184443_400x240.jpg
blog: "true"
dir: posts
---

‌‌‌‌　　在 Linux 虚拟机中，若未安装 acpid 服务，虚拟机可能无法正确响应 Proxmox VE 发送的 ACPI 关机信号，从而导致关机按钮无效。例如，虚拟机在未安装系统时，点击 Proxmox VE 界面中的关机按钮，虚拟机不会执行关机操作。这个时候我们就只能用 `qm stop` 命令对虚拟机进行强制关机。

## 1. 进入系统 Shell  

首先选择节点名称，本例中为 `pve`，然后在右侧选择 Shell：  
![](attachments/94ae6e976b4fdb3426a2efd9114d6d33_MD5.jpg)

## 2. 在 shell 中输入关机命令  

‌‌‌‌　　在 Shell 中需要输入虚拟机的 ID（上图中的黄色部分），例如，若要强制关闭 ID 为 `100` 的虚拟机，则应使用命令 `qm stop 100`。这个命令会立即停止虚拟机，类似于拔掉正在运行的电脑电源一样，这可能会损害虚拟机的数据。  

**命名详细用法：**
```shell
qm stop <vmid> [OPTIONS]
停止虚拟机。qemu 进程将立即退出。这类似于拔掉正在运行的计算机的电源插头，可能会损坏 VM 数据。

<vmid>: <integer> (100 - 999999999) VM的（唯一）ID。
[OPTIONS]：
  --keepActive <boolean> (default = 0) 不要停用存储卷。
  --migratedfrom <string> 集群节点名称。
  --overrule-shutdown <boolean> (default = 0) 尝试在停止之前中止活动的qm关闭任务。
  --skiplock <boolean> 忽略锁-只允许root使用此选项。
  --timeout <integer> (0 - N) 等待超时时间秒。
```
