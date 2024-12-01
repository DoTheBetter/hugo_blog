#!/bin/bash

grep -oP '<loc>\K[^<]+' public/sitemap.xml > sendurl/allurl.txt

cd sendurl

[ ! -f "baidu_success.txt" ] && touch baidu_success.txt

# 执行 grep 命令并将结果存储在变量中
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