# 飞书/Lark 环境变量模板

仅保存在运行 Gateway 的本机 Profile `.env` 中；不要提交到 Git，也不要发送到聊天。

默认 Profile：`~/.hermes/.env`

命名 Profile：`~/.hermes/profiles/<profile>/.env`

```dotenv
FEISHU_APP_ID=cli_请填入真实AppID
FEISHU_APP_SECRET=请填入真实AppSecret
FEISHU_DOMAIN=feishu
FEISHU_CONNECTION_MODE=websocket

# 初次上线：使用配对，仅允许已批准用户。
FEISHU_ALLOW_ALL_USERS=false
FEISHU_ALLOWED_USERS=
FEISHU_GROUP_POLICY=allowlist

# 可选：在目标飞书会话输入 /sethome 后由 Hermes 自动保存。
# FEISHU_HOME_CHANNEL=oc_真实群或会话ID

# 仅在已有公网 HTTPS 回调入口时改为 webhook，并填写下面两个值。
# FEISHU_CONNECTION_MODE=webhook
# FEISHU_VERIFICATION_TOKEN=请填入真实VerificationToken
# FEISHU_ENCRYPT_KEY=请填入真实EncryptKey
```
