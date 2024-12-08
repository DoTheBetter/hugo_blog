---
title: 威联通QNAP Container Station 配置Docker镜像源的方法
date: 2024-12-08T19:43:03+08:00
lastmod: 2024-12-08T19:53:29+08:00
tags:
  - QNAP
  - Docker
  - NAS
description: 这篇文章介绍了如何配置威联通 QNAP NAS 设备上的 Container Station 使用 Docker 镜像源。作者首先介绍了两种方法：通过 Container Station 的图形界面添加镜像源，以及修改 docker.json 配置文件的方式。文章详细说明了每种方法的步骤，并附上了相应的截图。最后，作者还提供了验证配置是否成功的命令。
categories:
  - NAS
  - 服务器
collections:
  - 威联通QNAP
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

‌‌‌‌　　威联通 QNAP Container Station 是一款专为威联通 NAS 设备量身定制的应用软件，集成了 LXD、Docker 和 Kata 等多种轻量级虚拟化技术，并且配备了直观易用的图形界面，让创建和管理容器变得轻松简单。  
‌‌‌‌　　对于像我这样的个人用户来说，最常用的就是其 Docker 功能。然而，由于国内网络环境无法直接访问 Docker Hub，因此需要在 Container Station 中设置备用的 Docker 镜像源，才能将其丰富的应用资源拉取到自己的 NAS 上。接下来，我将介绍两种设置方法。  

## 1. 方法一：通过 Container Station 界面添加  

### 1.1. 添加 Docker 镜像源  

`Container Station 容器工作站` → `存储库` → `自定义存储库` → `添加`：  
![](attachments/ae007e35de03f7628045d78a29f2fd11_MD5.jpg)  

在弹出的界面中，提供商选择**其他**，名称随意填写，URL 填写**镜像源地址**，**注意不带最后的/**。填写完成后点击 `测试连接`, 提示连接成功后就可以点击 `应用` 了。  
![](attachments/5acbd0e4fd7a7909fbbab6cbf41ad718_MD5.jpg)

### 1.2. 拉取 Docker 镜像  

`Container Station 容器工作站` → `映像` → `提取` → `提取映像`：  
存储库选择刚才设置的**镜像源名称**，填入要下载的镜像名称及标签，勾选 `将存储库设置为默认设置`，最后点击 `提取`。  
![](attachments/ee7f702493acdddc147fcfabfdb6ddd4_MD5.jpg)

## 2. 方法二、修改 docker. Json 配置文件  

### 2.1. Container Station 的 docker 配置

‌‌‌‌　　为了在 Docker 中添加镜像源，我们可以按照常规方法修改它的配置文件。  
‌‌‌‌　　通常情况下，在一般的系统中，Docker 的配置信息都保存在 `/etc/docker/daemon.json` 这个路径下。但是，对于威联通 QNAP 平台上的 Container Station 来说，文件的位置有些特殊。它会储存在 Container Station 安装所在的硬盘上。想要找到该配置文件的精确位置，可以使用 `find / -name docker.json` 命令进行搜索。一般情况下，这个文件位于 `/share/CACHEDEV1_DATA/.qpkg/container-station/etc/docker.json` 这个路径中。

### 2.2. 添加 Docker 镜像  

打开 docker. Json 编辑
```shell
{
"registry-mirrors": [
    "https://docker.fxxk.dedyn.io",
    "https://hub.geekery.cn"
    ],
     ......
}
```

重启 container-station 生效：  
`/etc/init.d/container-station.sh restart`

再验证一下是否修改成功：  
`docker info`
