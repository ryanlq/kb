#!/usr/bin/env bash
# kb 一键安装：curl -fsSL https://raw.githubusercontent.com/ryanlq/kb/main/install.sh | bash -s -- [--pass <SURREAL_AGENT_PASS>]
set -euo pipefail

REPO="https://github.com/ryanlq/kb.git"
RAW="https://raw.githubusercontent.com/ryanlq/kb/main"
DEST="${KB_HOME:-$HOME/.agents/skills/kb}"
PASS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --pass) PASS="$2"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

echo "==> 安装 kb skill 到 $DEST"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

fetch() {
  if [ -n "${KB_LOCAL:-}" ]; then
    echo "    (KB_LOCAL 本地模式：从 $KB_LOCAL 复制，供无 GitHub 访问的机器）"
    mkdir -p "$TMP/kb"; cp -r "$KB_LOCAL"/. "$TMP/kb/"; return
  fi
  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 "$REPO" "$TMP/kb" 2>/dev/null && return
  fi
  echo "    (git 不可用或失败，改用 tarball）"
  curl -fsSL "$RAW/tarball/main" -o "$TMP/kb.tgz"
  mkdir -p "$TMP/kb"; tar -xzf "$TMP/kb.tgz" -C "$TMP/kb" --strip-components=1
}
fetch

mkdir -p "$DEST/bin"
cp "$TMP/kb/SKILL.md" "$DEST/SKILL.md"
cp "$TMP/kb/bin/kb" "$DEST/bin/kb"
chmod +x "$DEST/bin/kb"
# 记录 origin，方便以后 cd 过去 git pull 更新
if [ ! -d "$DEST/.git" ] && command -v git >/dev/null 2>&1; then
  (cd "$DEST" && git init -q && git remote add origin "$REPO") 2>/dev/null || true
fi

echo "==> 写入全局指令"
SNIPPET='<!-- kb-skill:start -->
## 知识库自觉记录
任何会话中，遇到以下时机主动使用 kb 技能（`~/.agents/skills/kb/SKILL.md`，命令 `kb`）：
开始多步骤任务 → kb plan；阶段性完成 → kb progress；踩坑得出可复用结论 → kb lesson；值得留的信息 → kb note。
纪律：有信息量才记，takeaway 一句话可复用，琐碎不刷屏。
<!-- kb-skill:end -->'
for F in "$HOME/.pi/agent/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"; do
  [ -d "$(dirname "$F")" ] || continue
  [ -f "$F" ] && grep -q "kb-skill:start" "$F" 2>/dev/null && continue
  printf '\n%s\n' "$SNIPPET" >> "$F"
  echo "  + $F"
done

if [ -n "$PASS" ]; then
  RC="$HOME/.bashrc"; [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.bashrc" ] && RC="$HOME/.zshrc"
  grep -q "SURREAL_AGENT_PASS" "$RC" 2>/dev/null || printf '\nexport SURREAL_AGENT_PASS="%s"\n' "$PASS" >> "$RC"
  # 密钥文件：非交互 SSH / cron 也能用（.bashrc 不一定被加载）
  printf '%s' "$PASS" > "$HOME/.kb_pass" && chmod 600 "$HOME/.kb_pass"
  export SURREAL_AGENT_PASS="$PASS"
  echo "==> SURREAL_AGENT_PASS 已写入 $RC + $HOME/.kb_pass"
fi

echo "==> 验证连接"
if [ -z "${SURREAL_AGENT_PASS:-}" ]; then
  echo "⚠ 未设置 SURREAL_AGENT_PASS（密码找管理员获取）。设置后："
  echo "    export SURREAL_AGENT_PASS=<密码>"
  echo "    $DEST/bin/kb list note -n 1"
else
  if "$DEST/bin/kb" list note -n 1 >/dev/null 2>&1; then
    echo "✓ kb 安装并验证通过：$DEST/bin/kb"
    echo "  试试：kb note \"hello from $(hostname)\" --title 安装成功"
  else
    echo "✗ 验证失败：检查 SURREAL_AGENT_PASS" >&2
    exit 1
  fi
fi
