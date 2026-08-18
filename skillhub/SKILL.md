---
name: hermes-feishu-codex-setup
description: 用官方流程指导本地配置 Hermes、飞书/Lark 与 Codex；不读取或传输凭证。
version: 1.0.0
author: 珊瑚涌现
license: MIT
metadata:
  hermes:
    tags: [hermes, feishu, lark, codex, onboarding]
---

# Hermes + 飞书/Lark + Codex 配置向导

## 身份与适用范围

这是独立的配置指引 Skill，不代表或隶属于 Hermes、飞书/Lark、OpenAI 或 Codex。相关名称和商标归各自权利人所有。

它只适合指导用户在自己的电脑和自己的账号下完成：

1. 安装并验证 Hermes；
2. 在飞书/Lark 开放平台创建自己的机器人应用；
3. 安装并登录 Codex CLI；
4. 通过 Hermes Gateway 将机器人接入飞书/Lark；
5. 在真实项目中完成一次 Codex 只读验证。

它不提供代运营、绕过平台限制、批量注册账号、远程控制、数据采集、广告营销或任何规避权限的能力。

## 不处理的数据与权限

- 不索取、读取、展示、保存或上传 App Secret、API Key、OAuth token、Cookie、密码、私钥、完整 `.env` 或完整日志；
- 不要求用户把凭证粘贴到聊天、截图、Skill 配置或第三方网页；
- 不修改防火墙、系统安全策略、代理、Git 凭证或其他应用配置；
- 不下载或运行远程脚本，不使用提权、删除目录、强制覆盖或安全策略绕过型命令；
- 不自动启动后台服务、创建机器人应用、发布飞书/Lark 应用或发送消息。

涉及账号登录、App Secret 输入、服务安装、后台启动、应用发布或外部消息发送时，必须先向用户说明将发生的动作、涉及的本机位置和预期结果，并取得用户当次明确确认。用户应在官方页面或本机交互界面自行完成账号登录与凭证输入。

## 官方资料

- Hermes 快速开始：<https://hermes-agent.nousresearch.com/docs/getting-started/quickstart>
- Hermes 配置：<https://hermes-agent.nousresearch.com/docs/user-guide/configuration>
- Hermes 飞书/Lark：<https://hermes-agent.nousresearch.com/docs/user-guide/messaging/feishu>
- Hermes Gateway：<https://hermes-agent.nousresearch.com/docs/user-guide/messaging/>
- 飞书开放平台：<https://open.feishu.cn/>
- Lark 开放平台：<https://open.larksuite.com/>
- Codex CLI：<https://developers.openai.com/codex/cli/>

官方文档和本机命令的 `--help` 输出优先于本 Skill；若版本不一致，应以官方资料为准。

## 指导流程

### 1. 先确认用户环境

先确认用户使用飞书还是 Lark、运行 Hermes 的系统、是否已有 Git 项目，以及是否已安装 Hermes 和 Codex。缺少信息时，只询问完成当前步骤必需的最少信息。

不要假设用户拥有管理员权限、公开 IP、域名、付费 API 或企业管理员权限。

### 2. Hermes 与 Codex 的最小验证

指导用户按官方文档安装 Hermes，并先完成以下无写入验证：

```bash
hermes --version
hermes doctor
```

指导用户按 Codex 官方文档登录，并在其真实 Git 项目中先做只读检查：

```bash
codex login status
codex exec --sandbox read-only "只读取当前项目：说明技术栈、启动方式和测试命令；不要修改文件。"
```

在执行第二条命令前，提醒用户在目标项目目录运行，并确认该项目不是包含敏感数据的目录。若用户未登录、诊断失败或项目不是 Git 项目，先解释原因，不要通过修改系统配置绕过。

### 3. 飞书/Lark 应用

引导用户仅在飞书或 Lark 官方开放平台创建自建应用，并启用机器人。建议采用官方推荐的长连接 WebSocket 方式，避免为新手开放公网回调地址。

建议最小权限与事件以 Hermes 官方飞书/Lark 文档为准。提醒用户：

- 应用必须按平台规则发布后才能供真实用户使用；
- App Secret 只能由用户在本机官方向导或对应本机环境中输入；
- 初次接入应采用配对或白名单，不应向所有用户开放；
- 一个 App ID 只应对应一套生产 Gateway 长连接。

### 4. Gateway 连接与真实验收

在用户明确确认后，才指导其运行 Hermes 官方 Gateway 向导或服务命令。优先使用：

```bash
hermes gateway setup
```

配置后，先查看状态，再由用户在自己的飞书/Lark 客户端发送测试消息，确认机器人实际回复。需要群聊时，先验证机器人仅在被 @ 时响应。

服务启动、停止、重启、定时投递、配对批准和应用发布均属于会影响本机或外部账号的动作；每次执行前都应再次取得用户确认。

## 完成标准

仅当以下条件真实满足时，才称为“配置完成”：

- Hermes 诊断没有阻塞问题，模型能真实回复；
- Codex 已登录，并完成一次真实 Git 项目的只读分析；
- 飞书/Lark 应用已按官方要求启用、配置并发布；
- Gateway 状态正常；
- 用户在私聊中收到机器人真实回复；
- 如需群聊，机器人只在被 @ 时真实回复。

任何一项未通过时，应明确写“未完成”并说明卡点。不要把“文件已写入”“服务进程存在”或“正在输入”当作真实验收成功。

## 对用户的说明

开始前，用清晰、简短的方式告知用户：这是本机配置指导；账号、凭证和应用发布均由用户自行控制；本 Skill 不会收集或上传凭证，也不会自动执行有外部影响的操作。
