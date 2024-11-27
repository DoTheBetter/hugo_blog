---
title: Obsidian绿色便携版制作
date: 2024-11-13T22:26:30+08:00
lastmod: 2024-11-27T18:17:48+08:00
description: 本文介绍了两种方法用于创建 Obsidian 的官方绿色便携安装包，一种是通过修改官方安装包及创建启动脚本，另一种是使用第三方工具实现便携。
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

## 一、制作官方绿色便携包

‌‌‌‌　　1、去 [https://github.com/obsidianmd/obsidian-releases](https://github.com/obsidianmd/obsidian-releases) 下载最新官方安装包，将 exe 后缀改成 zip ，解压第一次，无视报错，选择你想要的版本比如 app-64.7z，解压第二次，就可以得到 64 位 Windows 的 Obsidian 安装包，免去安装步骤。

![](attachments/9e0e4249c014a7a18077eaee7daaf21d66fa45c8.png)

‌‌‌‌　　2、便携启动脚本，在 Windows 自带记事本中粘贴以下代码，保存时选择**所有文件**，文件名后添加 **.bat**：

```shell
@echo off
cd %~dp0
start "" "app\Obsidian.exe" "--user-data-dir=.\-obsidian-" /min
```

**解释：**
- `start "" "app\Obsidian.exe" "--user-data-dir=.\-obsidian-" /min`：
    - `start` 命令表示启动
    - 第一个引号是为标题参数留的（在本例中为空）。
    - 第二个引号将 `app\Obsidian.exe` 括起来，表示需要启动的程序。
    - 第三个引号为 Obsidian 启动参数，表示指定 Obsidian 配置文件夹。
    - `/min` 参数用于最小化窗口。
‌‌‌‌　　
最后将该 bat 文件放在 Obsidian. exe 上级目录，使用的时候双击这个 bat 文件。

‌‌‌‌　　3、最终目录为：

‌‌‌‌　　![](attachments/29d4295436a1c776881f45002af5fe0c_MD5.png)

## 二、第三方便携安装程序

‌‌‌‌　　1、[https://github.com/Numstr/Obsidian-Portable](https://github.com/Numstr/Obsidian-Portable)

‌‌‌‌　　
