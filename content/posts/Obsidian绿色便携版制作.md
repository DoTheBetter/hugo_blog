---
title: Obsidian绿色便携版制作
date: 2024-11-13T22:26:30+08:00
lastmod: 2024-12-05T20:01:54+08:00
description: 本文介绍了两种方法用于创建 Obsidian 的官方绿色便携安装包。一种是通过修改官方安装包及创建启动脚本，另一种是使用第三方工具实现便携。这两种方法都适用于希望在不同设备上轻松携带和使用的用户。
tags:
  - 软件
  - Obsidian
  - 绿色便携包
  - Windows
categories:
  - 使用技巧
  - Obsidian相关
collections:
  - Obsidian
  - 绿色便携
featuredImage: 
featuredImagePreview: ""
blog: "true"
dir: posts
---

## 1. 制作官方绿色便携包

### 1.1. 下载官方包

去 [https://github.com/obsidianmd/obsidian-releases](https://github.com/obsidianmd/obsidian-releases) 下载最新官方安装包，将 exe 后缀改成 zip ，解压第一次，无视报错，选择你想要的版本比如 app-64.7z，解压第二次，就可以得到 64 位 Windows 的 Obsidian 安装包，免去安装步骤。

![](attachments/9e0e4249c014a7a18077eaee7daaf21d66fa45c8.png)

### 1.2. 便携启动脚本

在 Windows 自带记事本中粘贴以下代码，保存时选择**所有文件**，文件名后添加 **. bat**：
```shell
@echo off
cd %~dp0
start /min "" "app\Obsidian.exe" "--user-data-dir=.\-obsidian-"
```

**解释：**
+ `start /min "" "app\Obsidian.exe" "--user-data-dir=.\-obsidian-"`：
    + `start /min` 命令表示最小化窗口启动。
    + 第一对引号是为标题参数留的（在本例中为空）。
    + 第二对引号 `app\Obsidian.exe` 表示需要启动的程序。
    + 第三对引号 `--user-data-dir=.\-obsidian-` 为 Obsidian 启动参数，表示指定 Obsidian 配置文件夹。‌

最后将该 bat 文件放在 Obsidian. exe 上级目录，使用的时候双击这个 bat 文件。更新 Obsidian 时只需清空替换 app 文件夹内的文件即可。

### 1.3. 最终目录

‌‌‌‌　　![](attachments/29d4295436a1c776881f45002af5fe0c_MD5.png)

## 2. 第三方便携安装程序

1. [https://github.com/Numstr/Obsidian-Portable](https://github.com/Numstr/Obsidian-Portable)
