# 新手验收记录

每一项填“通过 / 未通过 / 不适用”，并附最短证据，不记录任何密钥。

| 项目 | 状态 | 最短证据 |
|---|---|---|
| Hermes 安装与诊断 |  | `hermes doctor` 无阻塞问题 |
| Hermes 模型 |  | 一次真实文字回复 |
| Codex 登录与诊断 |  | `codex login status`、`codex doctor --summary` |
| Codex 项目只读 |  | 真实 Git 项目分析 + Git 工作区无新增修改 |
| 飞书应用能力 |  | 机器人已启用 |
| 飞书权限与事件 |  | 最小权限 + `im.message.receive_v1` |
| 飞书版本发布 |  | 已发布并获企业管理员批准（如需要） |
| Gateway 服务 |  | `hermes gateway status` 正常；不共享 `--deep` 原始日志 |
| 飞书私聊 |  | 实际消息和机器人最终回复 |
| 飞书群聊 |  | @机器人后实际回复 |
| Home Chat（如需 Cron） |  | `/sethome` 后实际投递 |

任何未通过项都必须保留为“未完成”，不能由“配置已保存”代替。
