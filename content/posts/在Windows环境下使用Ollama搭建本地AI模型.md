---
title: 在Windows环境下使用Ollama搭建本地AI模型
date: 2024-11-13T22:26:30+08:00
lastmod: 2024-12-05T20:08:44+08:00
description: 本文介绍了怎么样在 Windows 环境下使用Ollama 搭建本地 AI 模型、使用方法及配套UI软件。
tags:
  - Windows
  - Ollama
  - AI模型
  - 本地部署
  - 开发环境
categories:
  - AI
collections: 
featuredImage: 
featuredImagePreview: ""
blog: "true"
dir: posts
---

## 1. 什么是 Ollama？

Ollama 是一个开创性的人工智能 (AI) 和机器学习 (ML) 工具平台，它彻底简化了 AI 模型的开发和使用流程。

在 AI 技术社区中，模型的硬件需求和环境配置一直是令人头疼的问题。Ollama 应运而生，正是为了解决这些关键痛点：
+ 它提供了一套直观高效的工具，无论你是 AI 专家还是初涉此道的新手，都能轻松上手。
+ Ollama 让先进的 AI 模型和计算资源变得触手可及，不再是少数人的「专利」。
+ 对 AI 和 ML 社区来说，Ollama 的出现具有里程碑意义，它加速了 AI 技术的普及，让更多人能够实践自己的 AI 创意。

## 2. Ollama 的独特优势

Ollama 能够从众多 AI 工具中脱颖而出，主要得益于以下几个关键特性：
+ **智能硬件加速**：Ollama 能自动识别并充分利用 Windows 系统中的最优硬件资源。无论是 NVIDIA GPU、[AMD GPU](https://ollama.com/blog/amd-preview)，还是支持 AVX、AVX2 指令集的 CPU，Ollama 都能实现针对性优化，大幅提升 AI 模型的运行效率。这意味着，你可以把更多精力放在项目本身，而不是纠结于复杂的硬件配置。
+ **零虚拟化要求**：告别繁琐的虚拟机搭建和复杂的环境配置。Ollama 让你能够直接开始 AI 项目开发，整个流程变得简单快捷。这种便捷性极大地降低了 AI 技术的入门门槛。
+ **丰富的开源模型库**：Ollama 托管了一个全面的 [开源 AI 模型库](https://ollama.com/library)，包括先进的图像识别模型 [LLaVA](https://llava-vl.github.io/)、Google 最新的 [Gemma 2 模型](https://www.sysgeek.cn/google-gemma-open-models/) 和微软的 [Phi-3 模型家族](https://www.sysgeek.cn/microsoft-phi-3-models/) 等。这个「AI 武器库」让你可以轻松尝试各种开源模型，无论是文字交流、图像处理还是其他 AI 任务，总能找到合适的工具。
+ **便捷的常驻 API**：Ollama 的常驻 API 会在后台默默运行，随时准备将 AI 功能无缝整合到你的项目中。这意味着，强大的 AI 能力可以自然而然地融入你的开发流程，无需复杂的额外设置。

通过这些精心设计的功能，Ollama 不仅解决了 AI 开发中的常见痛点，还大大降低了 AI 技术的应用门槛，为 AI 的广泛应用铺平了道路。

## 3. 为什么要在 Windows 环境下搭建本地 AI 模型

本来准备在 NAS 里搭建本地 AI 模型的，但是 NAS 的 CPU 实在太弱了，测试的时候 CPU 直接 100%，而 windows 电脑配置高很多，CPU、显卡、内存都不错，浪费可惜了。直接用 Ollama windows 端搭建本地 AI 模型，不再用 Hyper-V 虚拟机或 Docker 中转浪费性能。

## 4. Ollama 安装与使用

### 4.1. 下载与安装

![下载 Ollama on Windows 版本](attachments/0414a9cd0bcabad6b278df1be6a60d28_MD5.png)

Ollama 现在已提供 Windows 版本，要求 Windows 10 及以上版本。下载地址可前往官网 [https://ollama.com/download/windows](https://ollama.com/download/windows)。下载完成后直接安装，不过安装过程中有个小缺点，就是不能选择安装路径，系统会自动将其安装在用户目录下。例如，默认安装路径可能为 `C:\Users\username\AppData\Local\Programs\Ollama`。

Ollama 默认会随 Windows 自动启动，你可以在「文件资源管理器」的地址栏中访问以下路径 `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`，删除其中的 `Ollama.lnk` 快捷方式文件，阻止它自动启动。

### 4.2. 环境变量设置

Ollama 有几个常用的系统环境变量参数需要设置。设置环境变量可以通过使用 Windows + R 快捷键打开「运行」对话框，输入命令 `C:\Windows\system32\rundll32.exe sysdm.cpl, EditEnvironmentVariables`，进入系统属性后在环境变量中进行设置。用户变量下新增变量记录即可完成环境变量的设置。
+ `OLLAMA_MODELS`： 用于设置模型文件存放目录。在 Windows 系统中，默认目录为当前用户目录下的 `C:\Users\%username%\.ollama\models`，为避免 C 盘空间不足，建议修改为其他盘符，如 `D:\OllamaModels`。
+ `OLLAMA_HOST`：是 Ollama 服务监听的网络地址，默认为 `http://localhost:11434` ，如果需要允许其他电脑访问 Ollama，比如在局域网环境中，可以设置为 `:8000`，只填写端口号可以同时侦听（所有） IPv4 和 IPv6 的 `:8000` 端口。
+ `OLLAMA_ORIGINS` ：默认只允许来自 127.0.0.1 和 0.0.0.0 的跨域请求，如果你计划在 LoboChat 等前端面板中调用 Ollama API，建议放开跨域限制，可以设置为 `*`
+ `OLLAMA_KEEP_ALIVE`：设置大模型加载到内存中的存活时间，默认为 `5m` 即 5 分钟，可以设置为纯数字表示秒数，负数表示一直存活，设置为 `24h` 可让模型在内存中保持 24 小时，提高访问速度。
+ `OLLAMA_MAX_LOADED_MODELS`：设置最多同时加载到内存中模型的数量，默认为 `1`。

![指定 Ollama on Windows 环境变量](attachments/d938b1bc0c5cd3edb359a7f821a8fcbd_MD5.png)

### 4.3. 管理本地已有大模型

> [!注意]  
> 你需要至少有 8GB 的内存来运行 7B 模型，16GB 来运行 13B 模型，以及 32GB 来运行 33B 模型。

1. 展示本地模型列表：可以使用 `ollama list` 命令查看本地已有的大模型。
```PowerShell
PS C:\Windows\system32> ollama list
NAME                         ID              SIZE      MODIFIED
glm4:9b-chat-q5_K_M          5941ffc5bb51    7.1 GB    10 hours ago
gemma2:9b-instruct-q5_K_M    272e1f3a41a6    6.6 GB    11 hours ago
qwen2.5:7b-instruct          845dbda0ea48    4.7 GB    12 hours ago
```
2. 删除单个模型：使用 `ollama rm 本地模型名称` 命令可以删除单个本地大模型。
3. 启动本地模型：使用 `ollama run 本地模型名` 命令可以启动本地模型，执行命令后，Ollama 会自动从模型库中下载并加载你所选的模型。例如 `ollama run qwen2:0.5b` 启动成功后，就可以通过终端对话界面进行对话。
4. 查看运行中模型列表：通过 `ollama ps` 命令可以查看本地正在运行的模型列表。
5. 复制本地大模型：使用 `ollama cp` 本地存在的模型名新复制模型名命令可以复制本地大模型。

### 4.4. 下载大模型方式

#### 4.4.1. 直接从远程仓库下载：这是最推荐、最常用的方式

1. 使用 `ollama pull` 命令直接从 Ollama 远程仓库下载或更新模型。例如：
```PowerShell
ollama pull qwen2:0.5b
```
2. 如果参数规格为默认值，可以省略具体版本号：
```PowerShell
ollama pull qwen2
```

#### 4.4.2. 通过 GGUF 模型权重文件运行

新版 ollama 已支持 GGUF 模型的直接下载与运行，不需再进行导入。  
运行格式为 `ollama run hf.co/{username}/{repository}:{quantization}` 。  
默认情况下，使用 `Q4_K_M` 量化方案。如果不存在，默认选择存储库中存在的合理量化类型。  

1. Huggingface
```PowerShell
#不使用标签或用latest标签，默认下载为q4_k_m
ollama run hf.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF
ollama run hf.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF:latest
#指定下载标签q5_k_m
ollama run huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF:q5_k_m
```
2. 国内 Huggingface 镜像
```PowerShell
ollama run hf-mirror.com/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF:q5_k_m
```
3. 国内魔搭社区
```PowerShell
ollama run modelscope.cn/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF:q5_k_m
```

#### 4.4.3. 通过 safetensors 模型权重文件导入

1. 将 safetensors 格式的模型文件放置在指定路径。
2. 使用 `ollama import` 命令导入模型。例如：
```PowerShell
ollama import path/to/your/safetensors/model.safetensors qwen2:0.5b
```

## 5. Ollama UI 软件

为了方便使用，本地应用无需部署，开箱即用，可以使用以下软件搭配 Ollama 使用：
+ [Chatbox](https://github.com/Bin-Huang/Chatbox) 是一个老牌的跨平台开源客户端应用，支持 Windows/MacOS/Linux/iOS/Android，基于 Tauri 开发，简洁易用。除了 Ollama 以外他还能够通过 API 提供另外几种流行大模型的支持。
+ [Cherry Studio](https://github.com/kangfenmao/cherry-studio) 是一款国产开源支持多个大语言模型（LLM）服务商的桌面客户端，兼容 Windows、Mac 和 Linux 系统。支持多款国内外最先进的 AI 大语言模型，AI 响应速度非常快，还能自由切换模型对话，不需要 Docker 环境，不需要使用任何命令行，点击鼠标就能安装。
