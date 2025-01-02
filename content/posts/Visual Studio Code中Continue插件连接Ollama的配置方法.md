---
title: Visual Studio Code中Continue插件连接Ollama的配置方法
date: 2025-01-02T10:21:39+08:00
lastmod: 2025-01-02T10:31:57+08:00
tags:
  - Ollama
  - VisualStudioCode
description: 文章介绍了如何在 Visual Studio Code 中使用 Continue 插件连接 Ollama 平台，以配置自定义的 AI 模型进行代码补全和聊天功能。通过设置 `config.json` 文件中的相关参数，可以灵活地选择不同的模型来满足个性化需求，从而实现高效便捷的编程辅助。
categories:
  - AI
collections: 
featuredImage: https://www.bing.com/th?id=OHR.CANYE24_ZH-CN3884754296_800x480.jpg
featuredImagePreview: https://www.bing.com/th?id=OHR.CANYE24_ZH-CN3884754296_800x480.jpg
blog: "true"
dir: posts
---

‌‌‌‌　　现在 Visual Studio Code 提供免费次数（回复限制为每月 2000 次代码完成和 50 条聊天消息）的 Copilot 使用，为避免在免费次数用尽后不得不付费的困扰，我们可以采用一种更加灵活多变的方法：结合使用代码生成模型、本地化的 Ollama 平台以及合适的 IDE 插件，例如，通过部署 Qwen 2.5 Coder 7B 模型，并搭配 Continue 延续插件，我们能够构建一个功能强大且自给自足的代码补全助手，临时替代 Copilot 的使用需求。通过这种方式，我们不仅能最大限度地发挥现有的开源技术和资源的价值，还可以根据个人需求进行定制化的编程辅助操作。这不仅为开发者提供了无限的创造空间，也使代码编写过程更加高效、便捷。  
‌‌‌‌　　Ollama 是一个创新性的 AI 和机器学习工具平台，它简化了 AI 模型的开发和应用流程，使得本地部署各种人工智能模型变得轻而易举。Continue 插件则是一个开源代码助手插件，能够连接多种 AI 模型，并与不同的上下文数据集成，在 Visual Studio Code 和 JetBrains 等 IDE 中提供自定义的自动补全和聊天功能。详细的安装教程在网络上已经有很多资源可供参考，下面主要来介绍一下如何配置 Continue 插件以使用 Ollama 里的模型。  

## 1. Continue 插件配置文件位置  

Continue 插件大多数自定义配置可以通过编辑 `config.json` 文件来完成。
1. 在 Windows 系统中的位置是 `%USERPROFILE%\.continue\config.json`。  
2. 通过 Visual Studio Code 的侧边栏也能找到这个文件：  
![](attachments/AA341FDCB056CB9B5DE9686CC739FD42_MD5.jpg)  

> [!NOTE] 说明  
> `config.json` 会在第一次使用 Continue 时创建。如果想将配置重置为默认值，可以删除此文件，Continue 将自动使用默认设置重新创建它。
>
> 保存 `config.json` 时，Continue 将自动刷新以实时更改。

## 2. Continue 插件配置 Ollama 模型  

### 2.1. 聊天模型  

+ `title` (**必需**)：模型的标题，显示在下拉菜单等中。
+ `provider` (**必需**)：模型的提供者，它决定了类型和交互方法。选项包括 `openai`、`ollama` 等。
+ `model` (**必需**)：模型的名称，用于提示模板自动检测。使用 `AUTODETECT` 特殊名称获取所有可用模型。
+ `apiKey`：OpenAI、Anthropic 和 Cohere 等提供商所需的 API 密钥。
+ `apiBase`：API 地址。

更多参数见官方配置说明： [config.json Reference | Continue](https://docs.continue.dev/reference)  

> [!NOTE] 说明  
> Continue 插件连接 Ollama 时，如果 Ollama 的 API 为默认值 `http://localhost:11434`，则 `apiBase` 可不用填写。

```json
"models": [
    {
      "title": "Qwen 2.5 Coder 7b",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b-instruct"
    },
    {
      "title": "glm4 9b-chat",
      "model": "glm4:9b-chat-q5_K_M",
      "provider": "ollama"
    },
    {
      "title": "gemma2 9b",
      "model": "gemma2:9b-instruct-q5_K_M",
      "provider": "ollama"
    }
  ],
```

### 2.2. 自动完成模型  

```json
"tabAutocompleteModel": {
    "title": "Qwen 2.5 Coder 7b",
    "provider": "ollama",
    "model": "qwen2.5-coder:7b-instruct"
  },
```

### 2.3. 嵌入模型  

```json
"embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text:latest"
  },
```
