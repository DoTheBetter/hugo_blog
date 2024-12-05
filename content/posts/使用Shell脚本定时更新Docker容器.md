---
title: 使用Shell脚本定时更新Docker容器
date: 2024-12-05T16:38:32+08:00
lastmod: 2024-12-05T16:52:58+08:00
tags:
  - docker
  - VPS
  - 脚本
description: 文章介绍了如何使用Shell脚本来定时检查并自动更新Docker容器，避免了在国内网络环境下使用watchtower服务遇到的技术障碍。该脚本能够扫描指定文件夹内的.yml文件，并通过docker-compose pull和docker-compose up命令来实现自动化更新及通知功能。
categories:
  - VPS
  - 服务器
collections:
  - 原创
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

‌‌‌‌　　在最近几个月里，我发现使用 `watchtower` 服务在国内更新 Docker 容器遇到了一些技术障碍，通常会收到这样的错误信息：`Reason: Get \\"https://index.docker.io/v2/\\": dial tcp 211.104.160.39:443: i/o timeout`。尽管我已经通过给 Docker 指定镜像来尝试解决这个问题，但仍然无法成功更新容器。因此，在查阅了许多在线资源之后，我决定编写一个可以在 VPS 上运行的独特脚本来解决这一困境。

## 1. 功能概述

‌‌‌‌　　该脚本主要负责扫描指定文件夹内的所有 `.yml` 文件，并用 `docker-compose pull` 来查找并获取可能存在的镜像更新；如果发现新版本的容器镜像时，则继续使用 `docker-compose up` 命令来升级现有的容器，同时发送通知告知用户更新的结果。除此之外，还能通过设定定时任务让整个过程自动化运行。

## 2. 技术细节

‌‌‌‌　　这个脚本的核心逻辑是根据 `docker-compose pull` 和 `docker-compose up` 这两个命令的输出日志是否包含特定字符串进行判断，以确定是否进行必要的容器更新操作。  
‌‌‌‌　　另一种可能的方式来实现镜像自动更新是直接对比镜像本地和远程仓库的哈希值，如果发现两者不匹配就拉取最新的版本。然而这种方法在实施过程中显得相对复杂一些，因此没有采用这种方式。

## 3. 完整脚本  

我的文档目录如下，如有不同请自行修改脚本路径：
```shell
/root
   ├── docker
   │   ├── …
   │   └── …
   ├── docker-manage.yml
   ├── docker-test.yml
   ├── docker-tools.yml
   └── docker-web.yml
```

脚本代码：
```shell
#!/bin/bash

# 定义要遍历的目录
TARGET_DIR="/root"

# 计划任务执行时间
TASK_TIME="0 */6 * * *"

# 通知设置
PREFIX="消息标题前缀"
MESSAGE_PUSHER_SERVER="消息服务器地址"
MESSAGE_PUSHER_USERNAME="用户名"
MESSAGE_PUSHER_CHANNEL="发送通道"
MESSAGE_PUSHER_TOKEN="发送通道的TOKEN"

# 通知发送函数
function send_message {
    curl -s -X POST "$MESSAGE_PUSHER_SERVER/push/$MESSAGE_PUSHER_USERNAME" \
        -d "title=$1&description=$2&content=$3&channel=$MESSAGE_PUSHER_CHANNEL&token=$MESSAGE_PUSHER_TOKEN&render_mode=code" \
        >/dev/null
}

# 遍历指定目录下的所有 .yml 文件
for YML_FILE in "$TARGET_DIR"/*.yml; do
    # 提取文件名作为 Docker 项目名称
    PROJECT_NAME=$(basename "$YML_FILE" .yml)

    # 使用 docker-compose pull 命令检查更新
   docker-compose -f "$YML_FILE" pull > $TARGET_DIR/update_$PROJECT_NAME.log 2>&1

    # 判断是否有镜像更新
    if grep -q "Pull complete" $TARGET_DIR/update_$PROJECT_NAME.log; then
       echo "$YML_FILE 中镜像更新已下载成功"
       # 更新容器
       echo "-------分隔符-----------" >> $TARGET_DIR/update_$PROJECT_NAME.log 2>&1
       docker-compose -f "$YML_FILE" -p $PROJECT_NAME up -d >> $TARGET_DIR/update_$PROJECT_NAME.log 2>&1
       # 判断容器更新是否成功，并发送通知
       if grep -q "Started" $TARGET_DIR/update_$PROJECT_NAME.log; then
           echo "$YML_FILE 中容器更新成功"
           send_message "[${PREFIX}] Docker 容器升级完成" "yml 文件：$YML_FILE" "$(cat $TARGET_DIR/update_$PROJECT_NAME.log)"
       else
           echo "$YML_FILE 中容器更新失败"
           send_message "[${PREFIX}] Docker 容器升级失败" "yml 文件：$YML_FILE" "$(cat $TARGET_DIR/update_$PROJECT_NAME.log)"
       fi
    else
       echo "$YML_FILE 中镜像已是最新版"
    fi
done

# 获取当前脚本文件的路径和名称
SCRIPT_PATH="$(readlink -f "$0")"

# 删除同名计划任务并重新添加
(crontab -l | grep -v "$SCRIPT_PATH" ; echo "${TASK_TIME} bash $SCRIPT_PATH > /dev/null 2>&1") | crontab -
```
