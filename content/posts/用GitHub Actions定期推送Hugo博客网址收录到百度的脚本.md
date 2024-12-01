---
title: 用GitHub Actions定期推送Hugo博客网址收录到百度的脚本
date: 2024-12-01T15:08:50+08:00
lastmod: 2024-12-01T20:58:28+08:00
tags:
  - Hugo
  - GitHubActions
  - 百度搜索网址收录
description: 本文介绍了如何使用GitHub Actions和Hugo生成静态网站后，通过脚本定期将未被百度收录的网页地址推送至百度。
categories:
  - 博客
collections:
  - Hugo
featuredImage: 
featuredImagePreview: ""
blog: "true"
dir: posts
---

‌‌‌‌　　之前使用 WordPress 时，主题自带了自动推送文章到百度的功能。不过现在我改用了静态博客 Hugo，无法直接通过修改主题实现同样的效果。好在百度提供了基于 curl 的推送 API 示例，我们可以在生成 Hugo 博客后，利用 curl 指令来手动推送文章链接。  
‌‌‌‌　　我参考了一位博主 [^1] 的代码，并进行了一些修改和优化。具体来说，新增了判断条件并去掉了通知功能。实现的基本原理是：Hugo 博客会将所有网页地址生成到 sitemap.xml 文件中，脚本从中取出未被成功收录的前 10 个网址，然后通过百度 API 进行推送。

## 1. sendurl_baidu.sh 脚本

脚本存放路径为 `sendurl/sendurl_baidu.sh`

```shell
#!/bin/bash
# 提取网址到allurl.txt文件
grep -oP '<loc>\K[^<]+' public/sitemap.xml > sendurl/allurl.txt

cd sendurl
# 是否存在baidu_success.txt文件，不存在则建立
[ ! -f "baidu_success.txt" ] && touch baidu_success.txt

# 进行文件比较
result=$(grep -v -F -x -f baidu_success.txt allurl.txt)

# 检查结果是否为空
if [ -n "$result" ]; then
  # 从allurl.txt中找到10条不在success.txt中的文本行 写入sendurl.txt
  # baidu API限制每个站点每天提交的数量为10 
  grep -v -F -x -f baidu_success.txt allurl.txt | head -n 10 > baidu_sendurl.txt

  # 调用百度API，并将结果写入result.txt
  curl -H 'Content-Type:text/plain' --data-binary @baidu_sendurl.txt "$baidu_apiurl" -o baidu_result.txt

  # 收录成功则追加 sendurl.txt 的内容到 success.txt 文件
  if grep -q "success" baidu_result.txt; then
    cat baidu_sendurl.txt >> baidu_success.txt
  fi

  echo -e "百度搜索网址收录同步结果：\n$(cat baidu_result.txt)"

else
  echo "百度搜索网址已全部提交，退出脚本"
fi
```

## 2. workflows 脚本

1. 上面的脚本中有一个 `$baidu_apiurl` 变量，需要在运行 workflows 脚本里引入。从<https://ziyuan.baidu.com/site/index>获取接口调用地址（需要登录百度帐号），格式为 `http://data.zz.baidu.com/urls?_site_=网站地址&_token_=准入密钥`，填入 Github 仓库的机密变量中，变量名为 `BAIDU_APIURL`。  
![](attachments/19667991d001d29c3cc7c2d57f21aa15_MD5.png)
2. 因为需要 `baidu_success.txt` 文件内容对比，所以每次运行后都要用 `git push` 保存成功的链接，以便下次不再推送。
3. 将代码放在 Hugo 生成静态网站之后：
```shell
- name: Run shell script
        run: |
          chmod +x ./sendurl/sendurl_baidu.sh
          ./sendurl/sendurl_baidu.sh
          if grep -q "success" ./sendurl/baidu_result.txt; then
             git config --global user.name 'github-actions[bot]'
             git config --global user.email 'github-actions[bot]@users.noreply.github.com'
             git add sendurl/
             git commit -m "sendurl changes"
             git push --set-upstream origin master
          else
             echo "百度搜索网址提交失败，退出"
          fi
        env:
          baidu_apiurl: ${{ secrets.BAIDU_APIURL }}   #脚本引入secrets变量
```

## 3. 可能的改进

1. 可以不需要 sendurl_baidu. sh 脚本，修改下相关路径就可以将里面的内容直接放在 workflows 脚本里运行。

[^1]: [脚本定期将hugo博客网址收录到百度](https://becool.vip/posts/tech/baidusiterecord/)
