---
title: Windows 包管理利器Chocolatey安装记录
date: 2024-11-13T22:26:30+08:00
lastmod: 2024-11-28T11:06:01+08:00
description: 本文介绍了 Chocolatey，一款类似于 Linux 的包管理工具，旨在简化 Windows 上的软件安装、更新和卸载流程。文章概述了Chocolatey的优势，包括解决软件依赖问题以及丰富的软件包资源库。还详细说明了通过 PowerShell 安装 Chocolatey 的步骤，包括环境变量的设置和基本的命令示例，如查看版本、搜索、安装、升级和卸载软件包。
tags:
  - Chocolatey
  - Windows
categories:
  - Windows
collections: 
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

## 1、 Chocolatey 简介与优势

Chocolatey 是 Windows 平台下一款强大的包管理工具，类似于 Linux 平台的 apt-get 和 yum。它能够快速安装、更新和卸载软件包，为 Windows 用户带来了极大的便利。

Chocolatey 的优势主要体现在以下几个方面。

首先，它可以解决软件依赖问题。在安装软件时，Chocolatey 会自动检测并安装所需的依赖项，确保软件能够正常运行。这大大减少了用户在安装软件过程中的繁琐操作和可能出现的错误。

其次，Chocolatey 拥有丰富的软件包资源。用户可以在 Chocolatey 的官方网站（[https://community.chocolatey.org/packages](https://community.chocolatey.org/packages)）上查看所有可以使用 Chocolatey 安装的东西，或者在命令行工具中进行搜索。

## 2、 安装 Chocolatey 的方法

### 2.1、 安装要求

- 支持的 Windows 客户端和服务器操作系统（可在旧操作系统上运行）
- PowerShell v 2+（由于 TLS 1.2 要求，从本网站安装的最低版本为 v 3 ）
- . NET Framework 4.8（如果您尚未安装，安装程序将尝试安装 .NET 4.8）

### 2.2、 通过 PowerShell 安装

1.首先，使用管理员模式运行 powershell
2.按照官方说明>，可设置环境变量更改默认软件安装位置

> [!NOTE] Title
> ### Installation
> 1. The package is installed into `$env:ChocolateyInstall\lib\<pkgId>`. The package install location is not configurable - the package must install here for tracking, upgrade, and uninstall purposes. The software that may be installed later during this process **is** configurable. See [Terminology](https://docs.chocolatey.org/en-us/getting-started/#terminology) to understand the difference between "package" and "software" as the terms relate to Chocolatey.

3.在 PowerShell 中设置 ChocolateyInstall 环境变量指向新的安装位置：

```powershell
$env:ChocolateyInstall = 'D:\Chocolatey'
[Environment]::SetEnvironmentVariable('ChocolateyInstall', $env:ChocolateyInstall, 'Machine')
```

4.根据官方文档，运行以下命令：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

![](attachments/2aaf016eb582f61271e1cd98aeecbc47_MD5.png)

安装完成后，环境变量会自动添加 ，Chocolatey 的安装位置在 D 盘的 Chocolatey 文件夹下。系统的 Path 变量也会自动添加 Chocolatey 安装的 bin 路径。

5.验证安装。安装完成后，验证 Chocolatey 是否正确安装，并检查版本：

```powershell
choco -v
```

![image-20240602185622094](attachments/5b7fc728bee73c7d51ad1daab6ed3930_MD5.png)

## 3、 Chocolatey 的使用

### 3.1、 查看版本

可以使用 choco -v 命令来查看 Chocolatey 的版本。这个命令非常简单直接，能够快速反馈当前安装的 Chocolatey 版本信息。例如，执行该命令后可能会显示 "Chocolatey v 0.11.3" 等版本号。

### 3.2、 查找软件

通过 choco search <package-name>命令可以轻松查找要安装的软件。比如，如果你想安装 Node. Js，可以在命令提示符或 PowerShell 中运行 choco search node. Js，这个命令将会搜索包含 "node. Js" 名称的软件包，并列出所有匹配的软件包。

### 3.3、 安装软件

安装软件也很方便，使用 choco install <package-name>命令即可。例如，要安装 Git，可以执行 choco install git。如果需要一次性安装多个软件包，可以像这样操作：choco install a b c… -y。

### 3.4、 升级软件

升级已安装的软件可以使用 choco upgrade <package-name>命令。这个命令会下载并安装指定软件包的最新版本。如果想要升级所有软件包，可以使用 choco upgrade all -y。

### 3.5、 卸载软件

用 choco uninstall <package-name>命令可以卸载指定的软件包。比如，要卸载之前安装的 Git，可以运行 choco uninstall git。

### 3.6、 列出包

1. 使用 choco list -lo 可以列出包，-lo 表示 --localonly，即列出本地安装的软件包。
2. 使用 choco list -li 或 choco list -lai 可以列出 Windows 系统已安装的软件，这里的 -i 需要配合 -l 使用，用于列出不归 Chocolatey 管理的程序。
