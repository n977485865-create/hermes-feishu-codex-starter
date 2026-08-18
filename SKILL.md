---
name: hermes-feishu-codex-starter
description: 用于零基础用户安装、配置并验收 Hermes、飞书机器人与 Codex CLI 的一体化工作流。
version: 1.3.0
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [hermes, feishu, lark, codex, onboarding, gateway]
    related_skills: [hermes-agent, codex, multi-agent-organization-operations]
---

# Hermes + 飞书 + Codex：零基础可用版

## 用途与完成标准

当用户希望把 Hermes 接入飞书，并在真实项目中使用 Codex CLI 时使用本技能。它面向第一次配置的用户，先完成一套单机器人、单人私聊、单项目的最小闭环；多机器人或定时任务只在这个闭环完成后增加。

完成不是“写完配置”。必须同时满足：

1. `hermes doctor` 没有阻塞问题，且 Hermes 模型认证可用；
2. `codex login status` 与一次真实只读项目任务都成功；
3. 飞书应用已启用机器人、权限与收消息事件，并已发布版本；
4. `hermes gateway status` 显示服务可运行；
5. 用户从飞书实际发一条测试消息，机器人以正确身份回复；
6. 需要定时投递时，在目标会话执行 `/sethome`，再单独测试投递。

不要把 App Secret、OpenAI API Key、OAuth token、完整 `.env`、二维码内容或聊天记录粘贴到聊天、文档、Git 仓库或截图中。

## 官方入口（先用这些链接）

| 内容 | 官方链接 | 作用 |
|---|---|---|
| Hermes 快速开始 | https://hermes-agent.nousresearch.com/docs/getting-started/quickstart | 安装与首次运行 |
| Hermes 配置 | https://hermes-agent.nousresearch.com/docs/user-guide/configuration | `config.yaml` 配置说明 |
| Hermes 飞书/Lark | https://hermes-agent.nousresearch.com/docs/user-guide/messaging/feishu | 权限、事件、连接模式与变量 |
| Hermes 消息 Gateway | https://hermes-agent.nousresearch.com/docs/user-guide/messaging/ | 服务、状态、聊天命令 |
| Hermes Windows 原生指南 | https://hermes-agent.nousresearch.com/docs/user-guide/windows-native | Windows 安装、Gateway 与启动项 |
| 飞书开放平台 | https://open.feishu.cn/ | 创建中国区飞书自建应用 |
| Lark 开放平台 | https://open.larksuite.com/ | 创建国际版 Lark 应用 |
| 飞书自建应用流程 | https://open.feishu.cn/document/develop-process/self-built-application-development-process?lang=zh-CN | 权限、测试、发布的官方流程 |
| Codex CLI 官方文档 | https://developers.openai.com/codex/cli/ | 安装、登录、项目开发 |
| Codex CLI 功能说明 | https://developers.openai.com/codex/cli/features/ | 常用能力与配置 |
| Codex GitHub 仓库 | https://github.com/openai/codex | 发行说明与问题排查 |

Hermes 文档与本机 `hermes <命令> --help` 是配置命令的最终依据；Codex 文档与本机 `codex --help` 是 Codex 命令的最终依据。版本升级后，不要照搬旧教程，应先重新运行这些帮助命令。

## 推荐架构

```text
你（飞书私聊或群里 @机器人）
        ↓
飞书自建应用 / Lark 应用
        ↓  长连接 WebSocket（不要求公网 IP 或域名）
Hermes Gateway（固定运行底座）
        ├── Hermes 模型提供商：负责聊天、工具与定时任务
        └── 可替换执行 Agent：Codex / Claude Code / WorkBuddy / TraeWork
               └── 在真实 Git 项目中负责规划、编码与测试
```

Hermes 与飞书不会因执行 Agent 而替换：它们始终负责消息入口、角色、会话、权限、定时任务与交付。执行 Agent 只是加载本 Skill 后在真实项目目录中完成编码、测试或只读验收的可选实现。

推荐先用 **WebSocket 长连接**：Hermes 主动连飞书，不必开放公网端口，也不需要自己配 webhook URL。只有已有稳定公网 HTTPS 网关时才选 webhook 模式。

Hermes 的模型认证和 Codex CLI 登录是两套独立状态：

- Hermes 使用 `hermes auth add openai-codex` 或 `hermes model` 配置模型提供商；
- Codex 使用 `codex login` 配置 CLI 登录；
- 两者都能用 ChatGPT/Codex OAuth，但“一个登录成功”不代表另一个必然可用，必须分别验证。

## 第一部分：安装并验证 Hermes

### 1. 安装

按官方快速开始页安装。安装后依次执行：

```bash
hermes --version
hermes setup
hermes doctor
```

在 `hermes setup` 中选择模型提供商。若使用 OpenAI Codex OAuth，可执行：

```bash
hermes auth add openai-codex
hermes auth status openai-codex
hermes model
```

认证页或浏览器授权只在本机完成；不要让他人代为输入账号密码。

### 2. 最小模型验证

完成模型设置后，用一个不写文件、不花费大量时间的问题测试：

```bash
hermes -z "请只回复：Hermes 模型连接正常"
```

只有确实收到正常回复才进入飞书配置。若失败，先运行 `hermes doctor`，再检查 `hermes auth status openai-codex` 或当前所选提供商；不要先折腾飞书。

## 第二部分：安装并验证 Codex CLI

### 1. 安装和登录

按 Codex 官方文档安装。已安装 npm 的常用方式：

```bash
npm install -g @openai/codex
codex --version
codex login
codex login status
codex doctor --summary
```

`codex login` 会引导浏览器登录。不要把 API Key 写进命令历史；如果选择 API Key 登录，按官方交互方式输入，不要在聊天中发送 Key。

`codex doctor --summary` 用于发现安装路径、升级、线程索引等问题；它出现“更新路径不一致”等诊断提示时，不要据此直接断言 Codex 不可用。先确认认证与网络正常，再以以下真实只读项目调用作为可用性的最终判断；只有认证、网络、项目访问或配置解析类失败才阻塞接入。

### 2. 在真实 Git 项目里做只读验证

进入已有项目目录。新项目才执行 `git init`；不要为了验证擅自改动现有项目的 Git 历史。

```bash
cd /你的/项目绝对路径
git status --short
codex exec --sandbox read-only "只读取当前项目：说明项目的技术栈、启动方式和测试命令；不要修改任何文件。"
```

验收规则：Codex 应给出基于项目文件的回答，且再次执行 `git status --short` 不应出现由本次验证产生的修改。认证成功但没有真实项目只读任务，不算 Codex 项目接入完成。

### 3. 可选：规划与执行分开

复杂工作推荐两次独立会话：规划只读，执行才允许写入。先在 `~/.codex/` 创建以下两个文件；模型名只有在本机账号实际支持时才填入，未知时删掉 `model` 两行，让 Codex 用默认模型。

`plan.config.toml`：

```toml
# 可选：model = "本机可用的规划模型"
# 可选：model_reasoning_effort = "medium"
```

`execute.config.toml`：

```toml
# 可选：model = "本机可用的执行模型"
# 可选：model_reasoning_effort = "high"
```

调用顺序：

```bash
codex exec -C /你的/项目绝对路径 -p plan --strict-config --sandbox read-only "先分析需求，给出实施步骤、影响文件和验收标准；不要改文件。"
codex exec -C /你的/项目绝对路径 -p execute --strict-config --sandbox workspace-write "依据已确认的方案实现修改；运行相关测试；不要提交、推送或部署。"
```

`-p plan` 和 `-p execute` 是两个独立 Codex 进程，不会在同一会话中自动切换。正式项目不要加 `--ephemeral`，以便后续用 `codex resume --include-non-interactive <thread_id>` 恢复会话。

## 第三部分：创建飞书应用

### 1. 优先用 Hermes 向导

在准备运行 Gateway 的那台机器上执行：

```bash
hermes gateway setup
```

选择 **Feishu / Lark**，优先选择扫码创建和 **WebSocket**。如果扫码创建不可用，向导会让你手动输入 App ID 和 App Secret。

重要：一个飞书 App ID 只能由一套生产 Gateway 长连接使用。不要把同一个 App ID 同时填进两台电脑或多个 Hermes Profile 并启动；否则常见结果是一个能连上、另一个反复掉线。

### 2. 手动创建应用时的飞书后台清单

打开飞书开放平台，创建“企业自建应用”，然后完成：

1. 在“凭证与基础信息”复制 App ID 与 App Secret；
2. 在“应用能力”启用机器人；
3. 在“权限管理”添加最小权限：
   - `im:message`
   - `im:message:send_as_bot`
   - `im:resource`
   - `im:chat`
   - `im:chat:readonly`
4. 推荐同时添加：
   - `im:message.reactions:readonly`
   - `admin:app.info:readonly`
   - `contact:user.id:readonly`
5. 在“事件与回调”选择 **长连接（WebSocket）**，订阅 `im.message.receive_v1`；
6. 在“版本管理与发布”创建并发布版本；企业账号需要管理员审批时，等审批完成。

没有发布版本，权限和事件不会对真实用户生效。只看到“已保存”不能算完成。

### 3. 手动变量模板（只在向导不能用时）

凭证只能保存在运行 Gateway 的 Profile `.env` 中。macOS/Linux 默认 Profile 使用 `~/.hermes/.env`，命名 Profile 使用 `~/.hermes/profiles/<profile>/.env`；Windows 原生默认 Profile 使用 `%LOCALAPPDATA%\hermes\.env`，命名 Profile 使用 `%LOCALAPPDATA%\hermes\profiles\<profile>\.env`。如果手动设置过 `HERMES_HOME`，则以该目录为准。可复制本技能 `assets/feishu-env-example.md`，然后只在本机填入真实值。

最小生产配置如下：

```dotenv
FEISHU_APP_ID=cli_请填写真实值
FEISHU_APP_SECRET=请填写真实值
FEISHU_DOMAIN=feishu
FEISHU_CONNECTION_MODE=websocket

# 初次接入建议使用配对，不要对所有人开放
FEISHU_ALLOW_ALL_USERS=false
FEISHU_GROUP_POLICY=allowlist
FEISHU_ALLOWED_USERS=
```

- 中国飞书使用 `FEISHU_DOMAIN=feishu`，国际 Lark 使用 `FEISHU_DOMAIN=lark`。
- 空的 `FEISHU_ALLOWED_USERS` 配合 `FEISHU_ALLOW_ALL_USERS=false` 用于首次配对；用户私聊机器人后，由管理员执行 `hermes pairing list` 与 `hermes pairing approve <配对码或用户标识>`。
- 已明确知道用户 Open ID 时，可把逗号分隔的 `ou_xxx` 写入 `FEISHU_ALLOWED_USERS`。
- 不要设置 `FEISHU_ALLOW_ALL_USERS=true` 作为长期生产方案。
- 群聊默认仍必须 `@机器人` 才会触发。不要设置 `FEISHU_REQUIRE_MENTION=false`，除非确实需要机器人读取所有群消息。

为保证同一个群里不同成员的对话彼此隔离，确认 macOS/Linux 的 `~/.hermes/config.yaml` 或 Windows 原生的 `%LOCALAPPDATA%\hermes\config.yaml` 中有：

```yaml
group_sessions_per_user: true
```

## 第四部分：安装、启动并验收 Gateway

### 1. 作为后台服务运行

先完成模型和飞书应用配置，再安装服务：

```bash
hermes gateway install --start-now
hermes gateway status
```

常用维护命令：

```bash
hermes gateway start
hermes gateway stop
hermes gateway restart
hermes gateway status
hermes logs
```

macOS 使用 launchd，Linux 通常使用用户级 systemd。Windows 10/11 原生安装时，`hermes gateway install` 使用当前用户的计划任务，并在受限环境下回退到“启动”文件夹；不要求管理员权限。无论系统是什么，只有基础状态正常且日志没有重复客户端、认证失败或缺少凭证，才继续做消息测试。

`hermes gateway status --deep` 会额外打印最近日志，只能在本机排障时使用；日志可能含有连接 URL 或其他敏感运行信息，禁止把原始 `--deep` 输出、`.env` 或日志文件发给他人。需要远程协助时，只摘录错误类型与时间，并遮住完整 URL、token、App ID 和用户 ID。

### 2. 真实消息验收（不可省略）

依次完成并记录结果：

1. 在飞书客户端找到机器人并发“你好”；
2. 若出现配对码，在运行 Gateway 的机器执行：
   ```bash
   hermes pairing list
   hermes pairing approve <配对码或用户标识>
   ```
3. 再向机器人发：`请只回复：飞书机器人已连接`；
4. 确认机器人在飞书中真实回复指定文字；
5. 在同一会话输入 `/sethome`（`/set-home` 也是别名），用于后续 Cron 或通知投递；
6. 在群里把机器人拉入群，发送 `@机器人 请只回复：群聊连接正常`，确认只有被 @ 时才响应。

排查顺序必须是：服务连接层 → 消息进入日志 → 用户授权/配对 → Agent 处理 → 飞书最终回复。出现“正在输入”或一个表情，不代表已经能正常回复。

### 3. 多 Profile / 多机器人规则

初学者先保持一个 Profile、一个 App、一个 Gateway。需要更多角色时：

- 一个角色一个 Profile、一个飞书 App、一个 Gateway；
- 复制 Profile 后先删除新 Profile 中所有 `FEISHU_*` / `LARK_*` 凭证，再重新执行该 Profile 的 `hermes gateway setup`；
- 可共享模型认证，但绝不能共享同一个飞书 App ID；
- 每个机器人分别完成私聊、群聊、配对、Gateway 状态和真实回复验收。

## 跨 Agent 使用

Hermes + 飞书始终是固定运行底座；Codex、Claude Code、WorkBuddy/CodeBuddy、TraeWork 只是可替换的项目执行 Agent。它们加载同一份 Skill 后，都必须把 Hermes 和飞书配置视为既有基础设施，不得擅自替换 Gateway、机器人应用、角色 Profile 或凭证。

本技能的核心结构兼容通用 `SKILL.md` 格式。不要只复制单个 Markdown 文件，应复制整个目录。

macOS/Linux 在 Skill 根目录执行：

```bash
bash scripts/install-execution-agent-skill.sh
```

Windows 在 PowerShell 执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-execution-agent-skill.ps1
```

该 Windows 执行策略仅对当前进程有效，不会永久修改系统设置。如只安装某一个 Agent，可用 macOS/Linux 的 `--target codex` 或 Windows 的 `-Target codex`；从 Git 项目根目录加 macOS/Linux 的 `--scope project` 或 Windows 的 `-Scope project` 则安装为项目级。各宿主的准确路径、显式调用方式和验收方法见 `references/cross-agent-installation.md`。

跨 Agent 使用不改变飞书安全边界：任何宿主都不得读取或发送 App Secret；仍必须完成真实私聊、群聊和目标会话投递验收。

## 常见故障

| 现象 | 优先检查 | 正确处理 |
|---|---|---|
| Hermes 能聊天，飞书不回复 | 应用是否发布、`im.message.receive_v1`、Gateway 日志 | 补齐事件/发布后重启 Gateway，再发真实消息 |
| Gateway 启动后反复断开 | 同一 App ID 是否在其他机器/Profile 启动 | 只保留一个生产 Gateway，给其他角色创建独立 App |
| 私聊收不到回复 | pairing 或 `FEISHU_ALLOWED_USERS` | `hermes pairing list`，再批准当前用户 |
| 群里机器人沉默 | 是否 @机器人、`FEISHU_GROUP_POLICY` | 先 @机器人；生产环境保留 `allowlist` |
| Codex 登录正常但不能改项目 | 工作目录不是 Git 项目、sandbox 不匹配 | 用真实项目路径；先只读验证，再用 `workspace-write` |
| Cron 没有投递到飞书 | 没有 home chat 或未验证目标 | 在目标会话执行 `/sethome`，再手动运行一次任务验证 |
| 想用 webhook 但收不到事件 | 公网 HTTPS、回调地址、验证 token | 新手改回 WebSocket；只有已有稳定公网入口才继续 webhook |

## 交付前验收清单

- [ ] 已打开官方链接并确认适用区域：飞书或 Lark。
- [ ] `hermes --version`、`hermes doctor` 成功。
- [ ] Hermes 模型有一次真实回复。
- [ ] `codex --version`、`codex login status` 成功；已阅读 `codex doctor --summary` 的阻塞性问题。
- [ ] Codex 在真实 Git 项目完成一次只读任务，Git 工作区未被本次验证改动。
- [ ] 飞书应用已启用机器人、最小权限、`im.message.receive_v1`、WebSocket，并发布版本。
- [ ] App Secret 只存在于对应 Profile 的本机 `.env`，未进入 Git 或聊天。
- [ ] `hermes gateway status` 正常，无重复 App ID 连接；如需要 `--deep` 排障，未共享原始日志。
- [ ] 私聊从飞书实测：配对/授权通过，机器人真实回复。
- [ ] 群聊从飞书实测：仅 @机器人时回复。
- [ ] 如需定时通知：已在目标聊天执行 `/sethome` 并实测投递。

如果任何一项未通过，交付状态应写“未完成”，并说明卡在哪一层；不得用“配置文件已写”或“服务进程存在”替代真实消息回归。
