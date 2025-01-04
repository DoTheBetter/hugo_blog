---
title: Caddy开启网站附件文件夹防盗链
date: 2025-01-04T09:02:30+08:00
lastmod: 2025-01-04T09:09:22+08:00
tags:
  - Caddy
  - 防盗链
  - Hugo
description: 本文介绍了如何在阿里云服务器上使用自制的 Caddy 服务器 Docker 镜像，通过配置防盗链规则来保护博客附件目录免受非法访问。文章详细展示了 Caddy 配置文件中的关键片段，并提供了应对空白 referer 的新策略参考链接。
categories:
  - 博客
collections: 
featuredImage: https://www.bing.com/th?id=OHR.VietnamFalls_ZH-CN9659529108_800x480.jpg
featuredImagePreview: https://www.bing.com/th?id=OHR.VietnamFalls_ZH-CN9659529108_800x480.jpg
blog: "true"
dir: posts
---

‌‌‌‌　　我的 Hugo 博客是部署于阿里云服务器之上，依托一个 [自制的Caddy 服务器Docker 镜像](https://github.com/DoTheBetter/docker/tree/master/caddy2) 构建而成。借助这一配置，我能够轻松地运用 Caddy 的功能来对博客的附件目录执行防盗链保护。以下是相应的 Caddy 配置文件片段：

```json
xxx.com {
          root * /www  # 网站根目录
          encode zstd gzip  # 启用 Gzip 压缩
        
          # 防盗链配置
          # 匹配请求头中没有referer
          @norefimgaccept {
              path /posts/attachments/*  # 添加需要保护的子目录
              header !Referer
          }
          # 匹配请求头中有referer，但是内容不匹配指定内容的
          @wrongref {
              path /posts/attachments/*  # 添加需要保护的子目录
              header Referer *
              not header Referer https://xxx.com/*
          }
          # 匹配的请求指向指定的防盗链图片
          rewrite @norefimgaccept /daolian.png
          rewrite @wrongref /daolian.png
        
          # 处理所有其他请求
          file_server  # 启用静态文件服务器
}
```

参考：[一种新的可应对空白 referer 的防盗链策略](https://github.com/wolfogre/blog-utterances/issues/30)
