# Codex 规划/执行 Profile（可选）

在 `~/.codex/` 中建立以下文件。模型名必须是本机账号真实可用的名称；不确定时不要写 `model`，让 Codex 使用默认配置。

## `plan.config.toml`

```toml
# model = "你的规划模型"
# model_reasoning_effort = "medium"
```

## `execute.config.toml`

```toml
# model = "你的执行模型"
# model_reasoning_effort = "high"
```

验证：

```bash
codex exec -C /项目绝对路径 -p plan --strict-config --sandbox read-only "只分析项目，不改文件。"
codex exec -C /项目绝对路径 -p execute --strict-config --sandbox workspace-write "只做已确认的小范围修改并运行相关测试；不要提交、推送或部署。"
```

首次使用先运行第一条。确认输出无配置错误且 Git 工作区无变化后，再使用执行 Profile。
