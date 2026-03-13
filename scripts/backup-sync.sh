#!/bin/bash
# OpenClaw 自动备份脚本
# 定时同步工作区和配置文件到 GitHub

WORKSPACE="/root/.openclaw/workspace"
OPENCLAW_CONFIG="/root/.openclaw"
BACKUP_DIR="/tmp/openclaw-backup"

# 从本地配置读取 token (不上传到 GitHub)
TOKEN_FILE="$BACKUP_DIR/.github_token"
if [ ! -f "$TOKEN_FILE" ]; then
    echo "错误：请创建 $TOKEN_FILE 文件并填入 GitHub token"
    exit 1
fi
GITHUB_TOKEN=$(cat "$TOKEN_FILE")
REPO_URL="https://${GITHUB_TOKEN}@github.com/baowanlong/openclaw.git"

cd "$BACKUP_DIR" || exit 1

# 拉取最新代码
git pull origin master --quiet 2>/dev/null

# 同步 workspace 目录
cp -r "$WORKSPACE"/* . 2>/dev/null

# 同步重要配置文件
mkdir -p .openclaw
cp "$OPENCLAW_CONFIG/openclaw.json" .openclaw/ 2>/dev/null
cp "$OPENCLAW_CONFIG/identity/"*.json .openclaw/ 2>/dev/null
cp "$OPENCLAW_CONFIG/cron/jobs.json" .openclaw/ 2>/dev/null
cp "$OPENCLAW_CONFIG/update-check.json" .openclaw/ 2>/dev/null
cp "$OPENCLAW_CONFIG/devices/"*.json .openclaw/ 2>/dev/null

# 检查是否有改动
if [ -z "$(git status --porcelain)" ]; then
    echo "无改动，跳过提交"
    exit 0
fi

# 提交并推送
git add -A
git commit -m "🤖 自动备份 - $(date '+%Y-%m-%d %H:%M:%S')"
git push origin master --quiet

echo "备份完成 - $(date '+%Y-%m-%d %H:%M:%S')"
