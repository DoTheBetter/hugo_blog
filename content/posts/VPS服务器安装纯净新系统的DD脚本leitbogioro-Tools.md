---
title: VPS服务器安装纯净新系统的DD脚本leitbogioro-Tools
date: 2024-11-19T10:17:36+08:00
lastmod: 2024-12-05T19:55:42+08:00
tags:
  - VPS
  - 脚本
  - 系统安装
  - 服务器管理
description: 使用一键DD脚本重装或更换VPS系统，推荐使用“leitbogioro”大佬的脚本，该脚本对Debian系列支持良好，并提供了详细的下载和安装步骤。
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

‌‌‌‌　　基本上所有的主机提供商都会提供免费的 Linux 系统以供安装使用，如 CentOS、Debian、Ubuntu 等。那为什么我们还要使用一键 DD 脚本重装/更换系统呢？
1. 商家提供的系统版本有限，可能没有自己需要的版本；
2. Windows 系统通过正规渠道安装需要收费
3. 商家提供的系统大多都是改装过的，不纯净，可能存在软件兼容行问题；
4. 商家提供的系统大多带有监控，特别是某里云，某鹅云，卸载监控和排查后门不是那么简单的。

## 1. DD 脚本的选择

‌‌‌‌　　网络上的 dd 脚本很多，对 vps 的支持可能不一样，这个脚本不行就换个脚本。我用的脚本是 "leitbogioro"/" 天权璇玑 " 大佬的脚本，这个脚本对 debian 支持很好。  
脚本地址：  
[https://github.com/leitbogioro/Tools](https://github.com/leitbogioro/Tools "https://github.com/leitbogioro/Tools")  
[https://www.nodeseek.com/post-9383-1](https://www.nodeseek.com/post-9383-1 "https://www.nodeseek.com/post-9383-1")  
[https://hostloc.com/thread-1159839-1-1.html](https://hostloc.com/thread-1159839-1-1.html "https://hostloc.com/thread-1159839-1-1.html")

## 2. 脚本用法

### 2.1. 准备工作

+ 如果你不是 root 用户，请尝试执行以下命令切换获取 root 用户权限：
```shell
sudo -s
```
切换到 root 用户的默认方向
```shell
cd ~
```
然后继续下载并执行这个脚本。

+ 依赖项和操作系统支持以下列表，以安装到脚本支持的操作系统：  
Debian 系列 (Debian / Ubuntu / Kali):
```shell
apt update -y
apt install wget -y
```

RedHat 系列，仅基于 RedHat 7+，grub2(CentOS / AlmaLinux / CloudLinux / RockyLinux / OracleLinux / Fedora / VzLinux / ScientificOS / RedHat Enterprise Linux / TennisOpenOS / AWS AmazonLinux / AlibabaCloudLinux 或 AliyunLinux / OpenAnolis)：
```shell
yum install wget -y
```

或者（适用于 Redhat 8+）：
```shell
dnf install wget -y
```

Alpine Linux：
```shell
apk update
apk add bash wget
sed -i 's/root:\/bin\/ash/root:\/bin\/bash/g' /etc/passwd
```

+ 下载：
```shell
wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
```

中国大陆服务器：
```shell
wget --no-check-certificate -qO InstallNET.sh 'https://gitee.com/mb9e8j2/Tools/raw/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh
```

### 2.2. 快速开始（**当且仅当脚本不加 -pwd -port -mirror 等参数时有效，如果加了，必须指定对应系统的发行版版本号！**）

#### 2.2.1. Debian 12

```shell
bash InstallNET.sh -debian # -debian 7-12：Debian 7 及更高版本，默认：12
```

#### 2.2.2. Kali rolling

```shell
bash InstallNET.sh -kali # -kali rolling/dev/experimental：支持 rolling/dev/experimental 三个分支，默认推荐：rolling
```

#### 2.2.3. Alpine Linux Edge

```shell
bash InstallNET.sh -alpine # -alpine 3.16-3.18/edge：Alpine Linux 3.16 及更高版本，默认推荐：edge
```

**Alpine Linux 是一种轻量级的 Linux 版本，对性能较低的机器比较友好，系统内存至少需要 256MB。**

#### 2.2.4. CentOS 9 stream

```shell
bash InstallNET.sh -centos # -centos 7 或 8/9-stream：CentOS 7 及更高版本，默认：9-stream
```

#### 2.2.5. AlmaLinux 9

```shell
bash InstallNET.sh -almalinux # -almalinux/alma 8/9 : AlmaLinux 8 及更高版本，默认：9
```

#### 2.2.6. RockyLinux 9

```shell
bash InstallNET.sh -rockylinux # -rockylinux/rocky 8/9 : RockyLinux 8 及更高版本，默认：9
```

#### 2.2.7. Fedora 39

```shell
bash InstallNET.sh -fedora # -fedora 38/39：Fedora 38 及更高版本，默认：39
```

#### 2.2.8. Ubuntu 22.04

```shell
bash InstallNET.sh -ubuntu # -ubuntu 20.04/22.04/24.04（测试版，不稳定，请勿在生产环境中安装！）：Ubuntu 20.04 及更高版本，默认：22.04
```

#### 2.2.9. 适用于工作站的 Windows 11 专业版

```shell
bash InstallNET.sh -windows # -windows 10/11/2012/2016/2019/2022：，默认：11
```

### 2.3. 高级用法

示例：

```shell
bash InstallNET.sh -debian/kali/ubuntu/centos/almalinux/rockylinux/fedora(os type) 11(os version) -architecture 64(os bit, not necessary) -port "your server port" -pwd 'your server password' -mirror "a valid url for linux image source" -dd/--image "dd image url" -filetype "gz or xz" -timezone "like Asia/Tokyo etc" --network "static"/--ip-addr 'x.x.x.x'(ip address) --ip-mask 'x.x.x.x'(subnet mask) --ip-gate 'x.x.x.x'(gateway) -firmware(Debian with hardware drivers)
```

参数说明：

+ **-lang/-language "cn, en 或 jp"**：此选项用于设置 Windows dd 映像的语言，例如：-windows 10 -lang "en"，cn 为简体中文，en 为英文，jp 为日文，默认为 en。对 Linux 发行版无效。
+ **-port ""**：可以预先指定系统的 ssh 端口，范围是 1~65535，此选项对安装 Windows 无效，**默认取决于原系统，如果获取该值失败，该值将回退为 '22'**。
+ **-pwd/-password ''**：可预先指定目标安装系统的 ssh 密码。支持 Redhat 系列、Debian/Kali 等原生安装方式，不适用于 AlpineLinux 以及 Ubuntu、Windows、Redhat 等需要使用 " 覆盖镜像包模式 "(dd) 安装的操作系统（仅适用于内存容量较低的环境）。建议整个密码之间包含几个撇号，如果密码中有一个或多个撇号，请使用 " '\ " 替换原来的撇号，以防止在 shell 中无法正确表达和处理！**默认为 'LeitboGi0ro'**。
+ **-hostname ""**：可以为新安装的 Linux 系统预先指定主机名，不建议使用空值或包含除连字符以外的特殊符号。如果您原系统的主机名是 "localhost"，或者为空，或者您希望随机指定（-hostname "random"），则该值的期望格式为 " 实例 - 服务器时间的年月日 - 服务器时间的时分 "。**默认值取决于原系统**。
+ **-dd/--image "DD image from a valid url"**：此参数用于 KVM 或 XEN 虚拟化平台中的 dd 模式。此选项适用于 " 覆盖打包映像模式 "。
+ **-filetype "gz/xz"**：确定 DD 文件类型，不仅支持 ".gz"（默认），还可以支持 ".xz"。
+ **-timezone "like Asia/Tokyo etc"**：表示手动分配时区，如果输入参数的格式不正确或当前操作系统不支持，则该值将恢复为 "Asia/Tokyo"。如果未分配该参数，则该值取决于客户机 IP 地址的地理位置，如果您使用代理通过 ssh 服务连接到服务器，则自动时区配置可能不适合您。此选项对 Windows 无效。
+ **-raid "0, 1, 5, 6 或 10"**：在 Debian 12、Kali rolling、CentOS 9-stream、AlmaLinux 9、RockyLinux 9、Fedora 38 上使用原生安装方式测试成功，raid 0、1、5、6 或 10 个磁盘的 raid 分区配方，不适合 dd 安装，raid 0 或 1 至少需要 2 个磁盘，raid 5 至少需要 3 个磁盘，raid 6 或 10 至少需要 4 个磁盘，**如果你的机器只有一块硬盘或者所有驱动器的容量不一样或者在虚拟环境中，请不要分配它！**
+ **-setdisk " 一个磁盘或全部磁盘的名称 "**：如果你的机器有 2 个或更多硬盘，并且每个硬盘在安装过程中都要格式化，你可以指定 -setdisk"all" 来启用它，数据是无价的，你应该小心处理它们！或者你可以允许系统安装在一个磁盘上，如 "vdc" 或 "/dev/sdb"，此参数仅适用于 Debian / Redhat 系列并且与 "-raid" 冲突。
+ **-swap/-virtualmemory/-virtualram " 数字，单位为 MB"**：默认为 "0"，表示不允许交换，您可以预先指定硬盘上的一定容量的空间来为目标系统启用交换，例如 "-swap '1024'" 分配 1GB 交换，不适用于 Raid、AlpineLinux、dd 模式。
+ **-filesystem "ext4 或 xfs"**：默认为 "ext4"，您可以为目标系统预先指定一种文件系统，仅适用于 Debian/Kali。
+ **-partition "mbr" 或 "gpt"**：默认为 "mbr"，您可以指定 "gpt" 使用 GUID 分区表格式化硬盘，如果当前硬盘容量超过 2TB，则会自动激活 "gpt" 分区配方，这仅适用于 Debian/Kali、单硬盘格式化环境，不适用于 Raid。
+ **--nomemcheck**：强制关闭内存检查，这样你就可以在目标机器的任意大小的内存上安装任意操作系统，至于安装是否成功则不能保证，**该选项仅用于故障排除**。
+ **--cloudkernel**：将正式的 Linux 内核替换为云内核，因为云计算平台的虚拟机环境中有许多不必要的硬件驱动，如打印机、扫描仪、声卡、USB 控制器等，这些驱动在后期将被消除，以帮助减少内存和硬盘的空间占用。在 raid 或 dd（Windows）模式下，将禁止安装云内核。--cloudkernel"0" 表示禁止强制安装 Linux 云内核，--cloudkernel"1" 表示允许强制安装云内核。此选项只对安装到 Debian 11+/Kali/AlpineLinux 有效。**在某些硬件（如 Oracle Cloud arm64 服务器）上执行云内核会导致 VNC 中的客户机显示被禁用，为避免这种情况，您可以分配 --cloudkernel"0" 切换到强制安装传统 Linux 内核**。对于 VMware 和 VirtualBox 的虚拟化，安装云内核将导致启动失败。
+ **–motd**：启用插入一组修改后的 MOTD（每日消息）脚本，以方便在通过 ssh shell 连接时检查服务器的执行状态，默认禁用，仅适用于 Debian/Kali/AlpineLinux。
+ **--bbr**：通过向 "/etc/sysctl. d/99-sysctl. conf" 添加参数和值来为当前内核启用 BBR
+ **--network "dhcp/auto" 或 "static/manual"** : 默认使用 DHCP 完成网络配置，如果你的云供应商是中小型商户，你的机器网络可能为静态，所以需要添加。相当于 add --ip-addr "" --ip-mask "" --ip-gate ""，如果添加了这个，后面三项就不要再分发了！一定要在命令最后添加。
+ **--networkstack "ipv4", "ipv6" 或 "dual"** : 通过读取相关配置手动指定一个支持的 IP 堆栈，而不是检查 IP 堆栈的连通性，"ipv4" 表示 IPv4 堆栈，"ipv6" 表示 IPv6 堆栈，"dual" 表示 IPv4 和 IPv6 双堆栈。确保对应堆栈的参数在分配之前必须在系统中指定配置。
+ **--ip-addr "IPv4 地址 "**：必须与 --ip-gate 和 --ip-mask 一起添加，这种情况下，--network "static/manual" 会自动分配。
+ **--ip-gate "IPv4 网关 "**：必须与 --ip-addr 和 --ip-mask 一起添加，这种情况下，--network "static/manual" 会自动分配。
+ **--ip-mask "IPv4 subnet musk"** : 必须和 --ip-addr 以及 --ip-gate 一起添加，这种情况下 --network "static/manual" 是自动分配的。
+ **--ip-dns "IPv4 DNS 服务器 "**：此项仅用于静态网络配置，默认为 1.0.0.1 和 8.8.4.4，您也可以更改其他 IPv4 DNS 服务器（如 8.8.8.8、9.9.9.9、4.4.2.2 等）来替换它。如果您的机器的网络是 DHCP，请不要分配它！
+ **--ip6-addr "IPv6 地址 "**：必须与 --ip6-gate 和 --ip6-mask 一起添加，这种情况下，--network "static/manual" 会自动分配。
+ **--ip6-gate "IPv6 网关 "**：必须与 --ip6-addr 和 --ip6-mask 一起添加，这种情况下，--network "static/manual" 会自动分配。
+ **--ip6-mask "IPv6 子网掩码 "** : 必须与 --ip6-addr 和 --ip6-gate 一起添加，这种情况下 --network "static/manual" 是自动分配的。
+ **--ip6-dns "IPv6 DNS 服务器 "**：这个只用于静态网络配置，默认是 2606:4700:4700::1001 和 2001:4860:4860::8844，你也可以更改其他 IPv6 DNS 服务器来替换它。如果你的机器的网络是 DHCP，请不要指定它！
+ **--setipv6 "0 is disabled"**：默认启用 IPv6，如果您的机器是 IPv4 堆栈，并且由 Racknerd 和 Virmach 等提供，它们将为 IPv4 堆栈服务器提供 IPv6 DNS，服务器将优先访问无效的 IPv6 网络，而不是 IPv4，您可以通过添加 --setipv6 "0" 来删除新操作系统中强制的所有 IPv6 模块，以避免上述情况。此选项对 Windows 无效。
+ **--adapter " 机器真实的网卡接口名称，如 ens3，enp6s0 等 "**：如果内核添加了参数 "net.ifnames=0" 或 "biosdevname=0"，则所有不同的网卡名称将被指向相同的，如 "eth0"，"eth1" 等。如果您知道网卡的真实名称并想让它们替换 "eth0"，请输入正确的值，如果您不确定它的真实名称，请不要分配它！
+ **--netdevice-unite**：此功能与 --adapter" 真实接口名称 " 效果相反，它将向内核添加 "net.ifnames=0 biosdevname=0" 将所有不同网络适配器的接口名称重定向为统一的 "eth0"，此项无需指定任何值，建议您在输入并开始安装操作系统之前，仔细备份网络适配器的真实名称！
+ **--autoplugadapter**：仅对 Debian/Kali 有效，/etc/network/interfaces 中的网络适配器连接方式将从 "allow-hotplug" 替换为 "auto"。 --autoplugadapter "0" 强制禁用，--autoplugadapter "1" 启用，默认启用。添加此项后，对于多接口环境，如果配置为 "auto" 的接口，无论是否插入网线，Debian/Kali 都会不断尝试使用 dhcp 唤醒并启动它，即使超时。使用 "allow-hotplug（Debian/Kali 安装程序的默认设置）" 进行设置将跳过此问题，但如果一个接口有超过 1 个 IP 或者它将连接到另一个网桥，则在系统重新启动时，接口的初始化将失败，在大多数 VPS 环境中，机器的接口应该是稳定的，因此将接口配置方法的默认设置从 "allow-hotplug" 替换为 "auto" 是一个更好的主意，但这会导致一些服务器花费很长时间启动（尝试激活所有网络适配器并等待 dhcp 致命时间）。因为默认配置方法 "allow-hotplug" 将导致网络适配器永久断开与主机的连接，除非在执行 "systemctl restart networking" 时重新启动系统，所以为了避免这种情况，所有有效网络适配器的配置方法将使用 "auto" 而不是 "allow-hotplug"。
+ **--fail2ban** : 安装并配置 fail2ban 以防止可疑的 ssh 端口爆破。为减少内存占用，内存小于 2GB 的服务器将自动禁用。--fail2ban "0" 强制禁用，--fail2ban "1" 强制启用。此选项对 Windows 无效。
+ **-netbootxyz**：使用 [netbootXYZ](https://netboot.xyz/) 手动安装其支持的操作系统，需要 VNC 访问进行操作，确保服务器的内存容量足以容纳安装目标系统的整个 iso 映像。**仅适用于具有 BIOS 固件的 AMD64/x86_64 架构。ARM64/aarch64 架构，任何架构的 UEFI 固件均不受支持**！
+ **--allbymyself**：手动安装该脚本支持的操作系统，必须有 VNC，此选项对 Redhat 系列无效。
+ **-mirror " 有效的 DIST 镜像 url"**：操作系统安装文件资源，您可以选择最接近您服务器实际位置的资源来加快安装速度。
+ **-firmware** : 指定 Debian 和 Kali 的驱动以支持老版本的硬件，如果你的服务器位于中国大陆，程序会切换到 ' 中国科学技术大学镜像 ( [https://mirrors.ustc.edu.cn/debian-cdimage/](https://mirrors.ustc.edu.cn/debian-cdimage/) )' 以加快下载速度，默认镜像来自 [http://cdimage.debian.org/cdimage/](http://cdimage.debian.org/cdimage/)。
+ **-architecture "32/i386 或 64/amd64 或 arm/arm64"**：操作系统位。程序将自动检测并将 CPU 架构从您的机器重定向到将要安装的新系统，如果您不熟悉它，请不要指定它！

### 2.4. SSH 或 RDP 服务的默认配置

**推荐的桌面终端客户端是 Xshell 或 Putty。**

#### 2.4.1. 默认用户名

对于 Linux：root

对于 Windows：Administrator

#### 2.4.2. 默认密码

对于 Linux：LeitboGi0ro

对于 Windows：Teddysun.com

#### 2.4.3. 默认端口

Linux：与原先系统一样，以终端方式登录，

**若没有指定其他 ssh 密码或端口，系统安装完成后，必须立即修改默认密码或改用 ssh key 登录，防止非法访问！**

Windows：3389  
