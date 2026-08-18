#!/usr/bin/env bash
# 将当前完整 Skill 安装到已检测到的执行 Agent 用户级或项目级目录。
# 不安装、不修改 Hermes Gateway 或飞书凭证。
set -euo pipefail

SKILL_NAME="hermes-feishu-codex-starter"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="auto"
SCOPE="user"
DRY_RUN=false
REPLACE=false

usage() {
  cat <<'EOF'
用法：
  bash scripts/install-execution-agent-skill.sh [选项]

选项：
  --target auto|all|codex|claude|workbuddy|traework|trae
  --scope user|project
  --dry-run
  --replace
  --help

默认：自动识别已安装的执行 Agent，并安装到用户级目录。
说明：此脚本只安装本 Skill，不安装或替换 Hermes、飞书 Gateway、机器人应用、Profile 或凭证。
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:?缺少 --target 的值}"; shift 2 ;;
    --scope) SCOPE="${2:?缺少 --scope 的值}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --replace) REPLACE=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$TARGET" in auto|all|codex|claude|workbuddy|traework|trae) ;; *) printf '不支持的目标：%s\n' "$TARGET" >&2; exit 2 ;; esac
case "$SCOPE" in user|project) ;; *) printf '不支持的范围：%s\n' "$SCOPE" >&2; exit 2 ;; esac

if [ "$SCOPE" = "project" ] && [ ! -d ".git" ]; then
  printf '项目级安装必须从 Git 项目根目录运行。\n' >&2
  exit 2
fi

has_command() { command -v "$1" >/dev/null 2>&1; }
has_path() { [ -e "$1" ]; }

is_detected() {
  case "$1" in
    codex) has_command codex ;;
    claude) has_command claude ;;
    workbuddy) has_command workbuddy || has_command codebuddy || has_path "$HOME/Library/Application Support/@genie/workbuddy-desktop" || has_path "$HOME/Library/Application Support/com.workbuddy.workbuddy" || has_path "/Applications/WorkBuddy.app" ;;
    traework) has_path "$HOME/.trae-cn" || has_path "/Applications/TraeWork.app" ;;
    trae) has_command trae || has_path "/Applications/Trae.app" || has_path "$HOME/.trae" ;;
  esac
}

install_to() {
  local agent="$1"
  local base="$2"
  local destination="$base/$SKILL_NAME"

  if [ "$DRY_RUN" = true ]; then
    printf '[预演] %s → %s\n' "$agent" "$destination"
    return
  fi

  mkdir -p "$base"
  if [ -e "$destination" ]; then
    if [ "$(cd "$destination" && pwd -P)" = "$SOURCE_DIR" ]; then
      printf '[跳过] %s：当前目录已是安装目录\n' "$agent"
      return
    fi
    if [ "$REPLACE" != true ]; then
      printf '目标已存在且不会被静默覆盖：%s。确认替换后重新执行并加 --replace。\n' "$destination" >&2
      return 2
    fi
    rm -rf "$destination"
  fi
  cp -R "$SOURCE_DIR" "$destination"
  printf '[完成] %s → %s\n' "$agent" "$destination"
}

base_for() {
  local agent="$1"
  if [ "$SCOPE" = "project" ]; then
    case "$agent" in
      codex) printf '%s/.agents/skills' "$PWD" ;;
      claude) printf '%s/.claude/skills' "$PWD" ;;
      workbuddy) printf '%s/.codebuddy/skills' "$PWD" ;;
      traework|trae) printf '%s/.trae/skills' "$PWD" ;;
    esac
  else
    case "$agent" in
      codex) printf '%s/.agents/skills' "$HOME" ;;
      claude) printf '%s/.claude/skills' "$HOME" ;;
      workbuddy) printf '%s/.codebuddy/skills' "$HOME" ;;
      traework) printf '%s/.trae-cn/skills' "$HOME" ;;
      trae) printf '%s/.trae/skills' "$HOME" ;;
    esac
  fi
}

agents=(codex claude workbuddy traework trae)
selected=()
if [ "$TARGET" = "auto" ]; then
  for agent in "${agents[@]}"; do
    if is_detected "$agent"; then selected+=("$agent"); fi
  done
elif [ "$TARGET" = "all" ]; then
  selected=("${agents[@]}")
else
  selected=("$TARGET")
fi

if [ "${#selected[@]}" -eq 0 ]; then
  printf '未识别到受支持的执行 Agent。可用 --target 指定：codex、claude、workbuddy、traework 或 trae。\n' >&2
  exit 1
fi

printf 'Hermes + 飞书底座不会被此脚本修改。安装范围：%s\n' "$SCOPE"
for agent in "${selected[@]}"; do
  install_to "$agent" "$(base_for "$agent")"
done

if [ "$DRY_RUN" = true ]; then
  printf '预演完成；移除 --dry-run 后执行实际复制。\n'
else
  printf '安装完成。重启对应执行 Agent 或新开会话后加载 %s。\n' "$SKILL_NAME"
fi
