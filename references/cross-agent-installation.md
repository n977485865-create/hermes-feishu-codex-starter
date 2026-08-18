# 固定 Hermes + 飞书，替换执行 Agent 的安装方式

本 Skill 的用途是让不同执行型 Agent（Codex、Claude Code、WorkBuddy/CodeBuddy、TraeWork）在真实项目中协助配置、验证或维护**同一套 Hermes + 飞书底座**。不要把执行 Agent 当作 Hermes Gateway 或飞书机器人的替代品。

所有宿主都必须复制完整 `hermes-feishu-codex-starter/` 目录，而不是只复制 `SKILL.md`；目录内的 `assets/`、`references/` 与 `scripts/` 是 Skill 的组成部分。

## 自动安装（推荐）

解压通用包后，在 Skill 根目录执行。

macOS/Linux：

```bash
bash scripts/install-execution-agent-skill.sh
```

Windows PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-execution-agent-skill.ps1
```

`-ExecutionPolicy Bypass` 仅对这一次 PowerShell 进程生效，不会永久修改系统执行策略。脚本会自动检测已安装的 Codex、Claude Code、WorkBuddy/CodeBuddy、TraeWork 与 Trae，并复制到相应的用户级目录；它不会安装、替换或修改 Hermes、飞书 Gateway、机器人应用、Profile 和任何凭证。

只安装某一个执行 Agent：

```bash
bash scripts/install-execution-agent-skill.sh --target codex
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-execution-agent-skill.ps1 -Target codex
```

支持的目标是 `codex`、`claude`、`workbuddy`、`traework`、`trae`。macOS/Linux 先加 `--dry-run`、Windows 先加 `-DryRun` 可只查看结果。目标已有同名 Skill 时，macOS/Linux 必须显式加 `--replace`，Windows 必须显式加 `-Replace` 才会覆盖。若要为当前 Git 项目安装，必须在项目根目录运行；macOS/Linux 加 `--scope project`，Windows 加 `-Scope project`。

## Codex（已在本机实测）

项目级：复制到项目根目录的 `.agents/skills/`：

```text
项目根目录/
└── .agents/skills/hermes-feishu-codex-starter/SKILL.md
```

用户级：复制到 `~/.agents/skills/hermes-feishu-codex-starter/`。

重启 Codex 后，在提示词写：`使用 $hermes-feishu-codex-starter 技能。`

## Claude Code

项目级：复制到项目根目录的 `.claude/skills/hermes-feishu-codex-starter/`。

用户级：复制到 `~/.claude/skills/hermes-feishu-codex-starter/`。

重启 Claude Code，在任务中明确写“使用 hermes-feishu-codex-starter Skill 配置或验证现有 Hermes + 飞书底座”。Claude 会根据 `name` 与 `description` 自动匹配，也可从技能菜单选择。

## WorkBuddy / CodeBuddy

当前 CodeBuddy/WorkBuddy 文档使用：

```text
项目根目录/.codebuddy/skills/hermes-feishu-codex-starter/
```

用户级位置为：

```text
~/.codebuddy/skills/hermes-feishu-codex-starter/
```

重启客户端或刷新 Skills 后，使用 `/hermes-feishu-codex-starter`，或在任务中明确要求加载该 Skill。若旧版 WorkBuddy 的设置页明确显示 `.workbuddy/skills/`，只把同一整个目录复制到该旧版实际显示的路径；不要同时运行两份并修改内容。

## TraeWork（中国版，非 Trae IDE）

官方文档：https://docs.trae.cn/work_skills

项目级位置：

```text
项目根目录/.trae/skills/hermes-feishu-codex-starter/
```

macOS/Linux 全局位置：

```text
~/.trae-cn/skills/hermes-feishu-codex-starter/
```

Windows 全局位置：

```text
%USERPROFILE%\.trae-cn\skills\hermes-feishu-codex-starter\
```

TraeWork 还支持在 Skills 面板导入根目录包含 `SKILL.md` 的 ZIP 或 `.skill` 包。因此使用专用的 `hermes-feishu-codex-starter-traework.zip`，不要使用带外层目录的通用复制包。导入后从 Skills 面板启用，或在任务中明确要求使用 `hermes-feishu-codex-starter`。

## 统一验收

无论选择哪个执行 Agent，先让它回答“本 Skill 中 Hermes + 飞书底座的完成标准”，再检查它能读取 `assets/feishu-env-example.md`。

真正的完成条件不变：Hermes 模型可用、飞书应用已发布、Gateway 正常、私聊真实回复、群聊 @真实回复；需要定时任务时还要有 `/sethome` 后的真实投递。任何执行 Agent 都不得读取、输出或上传 App Secret、OAuth token、完整 `.env` 或 Gateway 深度日志。
