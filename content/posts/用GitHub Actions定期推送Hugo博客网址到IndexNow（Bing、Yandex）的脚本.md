---
title: 用GitHub Actions定期推送Hugo博客网址到IndexNow（Bing、Yandex）的脚本
date: 2024-12-02T10:30:59+08:00
lastmod: 2024-12-02T20:11:59+08:00
tags:
  - GitHubActions
  - Hugo
  - IndexNow
  - Bing
  - Yandex
description: 本文介绍了如何使用GitHub Actions定期推送Hugo博客网址到IndexNow，从而通知Bing和Yandex搜索引擎更新内容。
categories:
  - 博客
collections:
  - Hugo
featuredImage: ""
featuredImagePreview: ""
blog: "true"
dir: posts
---

‌‌‌‌　　网上有很多教程教你如何使用 Bing 自己的 API 推送，但实际上使用 IndexNow 的 API 会更加便捷。那么 IndexNow 是什么呢？你可以访问其中文页面 [^1] 来了解更多详情——IndexNow 是一个简单的 Ping 功能，用于通知搜索引擎一个新的 URL 及其内容已被添加、更新或删除，从而帮助搜索引擎更快地在搜索结果中反映这些更改。  

‌‌‌‌　　目前，IndexNow 已经获得了许多搜索引擎的支持，对我们最有用的就是 Microsoft 必应（Bing）和 Yandex。这意味着只需使用 IndexNow 的 API 推送一次，就能同时推送到支持 IndexNow 的其他搜索引擎。  

‌‌‌‌要使用 IndexNow，大致需要三步：
1. 生成 API 密钥；
2. 上传密钥文件到 GitHub；
3. 使用 HTTP 向搜索引擎提供的 URL 发出 POST JSON 请求。  
详细的使用方法见 Bing 的 IndexNow 页面 [^2] 及 IndexNow 中文文档 [^3]。
  
‌‌‌‌　　在 GitHub Actions 中使用 IndexNow 很方便，已经有大佬编写了一个可以直接在 workflows 脚本使用的 Actions[^4]，可以把设定更新时间内的地址自动提交给搜索引擎。  

‌‌‌‌　　下面是我的一个具体例子：只需在你的 GitHub 仓库中添加一个名为 `INDEXNOW_KEY` 的机密变量，并将其值设置为 " 您的 API 密钥 "。这样，你就可以省去后面第 2 和第 3 步的操作。

具体操作步骤如下：
1. **生成 API 密钥**：访问 Bing IndexNow 页面 [^2] 并生成你的 API 密钥
2. **在 GitHub 仓库中设置机密变量**：`INDEXNOW_KEY`
3. **编写 workflows 脚本**，将代码放在 Hugo 生成静态网站之后
```yml
 ### … 省略其他步骤

 - name: Setup IndexNow
   # 动态生成KEY文件以防止它们在公共存储库中泄露。
   run: echo ${{ secrets.INDEXNOW_KEY }} > public/${{ secrets.INDEXNOW_KEY }}.txt

 - name: Indexnow-action
   uses: bojieyang/indexnow-action@v2
   with:
     # https://github.com/bojieyang/indexnow-action
     sitemap-location: "https://your-website.com/sitemap.xml"
     since: 1
     since-unit: "week"
     endpoint: "www.bing.com"
     key: ${{ secrets.INDEXNOW_KEY }}
     key-location: https://your-website.com/${{ secrets.INDEXNOW_KEY }}.txt

### … 省略其他步骤
```

[^1][IndexNow.org](https://www.indexnow.org/zh_cn/index)  
[^2][IndexNow | Bing Webmaster Tools](https://www.bing.com/indexnow/getstarted#implementation)  
[^3][文档 | IndexNow.org](https://www.indexnow.org/zh_cn/documentation)  
[^4][bojieyang/indexnow-action](https://github.com/bojieyang/indexnow-action/blob/main/README.zh.md)
