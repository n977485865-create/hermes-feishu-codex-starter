# Hermes + 飞书 + Codex Starter Skill

一份面向新手的可复用 Skill：用 Hermes 作为消息与自动化底座，接入飞书/Lark，并在真实 Git 项目中使用 Codex CLI 完成规划、开发和验证。

## 它解决什么

- 从零配置 Hermes、飞书机器人和 Codex CLI 的最小可用闭环；
- 推荐飞书 WebSocket 长连接，不要求公网服务器；
- 明确区分 Hermes 模型认证与 Codex CLI 登录；
- 以真实私聊、群聊和项目只读任务作为验收，而不是只写配置；
- 提供安装到 Codex、Claude Code、WorkBuddy/CodeBuddy、TraeWork、Trae 的脚本。

## 边界

Hermes + 飞书始终是固定底座。Codex、Claude Code、WorkBuddy/CodeBuddy 和 TraeWork 只是项目执行 Agent，不应替换 Gateway、飞书应用、Profile 或凭证。

本仓库不包含也不要求提交 App Secret、OAuth token、API Key、`.env` 或 Gateway 日志。

## 使用方式

将整个仓库目录复制到你的 Skill 目录，或使用安装脚本。

macOS / Linux：

```bash
bash scripts/install-execution-agent-skill.sh
```

Windows PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-execution-agent-skill.ps1
```

只安装到 Codex：

```bash
bash scripts/install-execution-agent-skill.sh --target codex
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-execution-agent-skill.ps1 -Target codex
```

如果目标位置已有同名 Skill，macOS / Linux 使用 `--replace`，Windows 使用 `-Replace` 明确确认后才会覆盖。

更多使用说明、验收标准、环境变量模板和跨 Agent 路径见：

- `SKILL.md`
- `references/cross-agent-installation.md`
- `assets/new-user-acceptance.md`
- `assets/feishu-env-example.md`

## 快速验收

完成配置后，至少确认：

1. `hermes doctor` 无阻塞问题，Hermes 模型能真实回复；
2. `codex login status` 成功，且 Codex 能在真实 Git 项目完成只读分析；
3. 飞书应用已启用机器人、最小权限、`im.message.receive_v1` 和 WebSocket，并发布版本；
4. `hermes gateway status` 正常；
5. 机器人在飞书私聊和群聊 @ 场景中均真实回复。

完整验收标准在 `SKILL.md`。

## 安全提示

- 不要把真实 `FEISHU_APP_SECRET`、OAuth token 或 `.env` 提交到 GitHub；
- 一个飞书 App ID 只应由一套生产 Gateway 长连接使用；
- 初次接入建议启用配对，避免对所有用户开放；
- Gateway 日志可能包含敏感连接信息，请勿公开原始日志。

## 许可证

本项目采用 [MIT License](LICENSE)。
