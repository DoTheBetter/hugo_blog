---
title: 重置Visual Studio Code快捷键
date: 2025-01-03T07:53:52+08:00
lastmod: 2025-01-03T07:54:27+08:00
tags:
  - 快捷键设置
  - 软件配置
  - VisualStudioCode
description: 本文详细介绍了如何在 Visual Studio Code 中重置快捷键设置的方法，包括找到全局快捷键设置的三种方式、修改快捷键的具体步骤以及如何清空 `keybindings.json` 文件以恢复默认设置。这对于解决插件冲突或需要调整软件默认配置的用户非常有帮助。
categories:
  - Windows
collections: 
featuredImage: https://www.bing.com/th?id=OHR.TolkienOxford_ZH-CN6331694590_800x480.jpg
featuredImagePreview: https://www.bing.com/th?id=OHR.TolkienOxford_ZH-CN6331694590_800x480.jpg
blog: "true"
dir: posts
---

‌‌‌‌　　在使用 Continue 插件时，我发现其启动快捷键 `Ctrl+I` 与 Visual Studio Code 自身的 Copilot 插件产生了冲突，因此我将 Continue 的快捷键调整为了 `Alt+I`。然而，当我想要恢复为默认快捷键设置时，却花了相当多时间才找到相关设置。以下是重新设置或更改快捷键的方法：

## 1. 首先找到全局快捷键设置  

有 3 种方式：  
1. 通过系统快捷键：先按 `Ctrl+K`，再按 `Ctrl+S`
2. 通过顶部菜单栏： `文件` > `首选项` > `键盘快捷方式`  
![](attachments/9AC102817E8FB72C6771AAD0AF11B85B_MD5.jpg)
3. 通过左下角的齿轮图标：  
![](attachments/D653A57CDE97415B100D99AF54477F94_MD5.jpg)

## 2. 修改快捷键

如果要重新修改快捷键，需要找到原来的快捷键设置再修改。点击 `显示用户按键绑定` 可以查看我们所有自定义修改过的快捷键。  
![](attachments/6E3384C67562CC7DB9F42C0484B20C48_MD5.jpg)

## 3. 重置快捷键  

如果想要重置 Visual Studio Code 的默认快捷键，清空 `keybindings.json` 文件内容保存即可。  
![](attachments/89D96EF36B81B6A379CBB63DAC40898A_MD5.jpg)
