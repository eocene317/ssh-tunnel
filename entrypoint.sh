#!/bin/bash

# 默认值（可通过环境变量覆盖）
: ${SSH_PORT:="22"}
: ${SSH_USER:="root"}
: ${LOCAL_SOCKS_PORT:="4402"}
: ${REMOTE_HOST_ALIVE_INTERVAL:=30}
: ${SSH_KEY_DEST:="/home/tunneluser/.ssh/id_rsa"}  # 容器内目标路径

# 检查 SSH_HOST 是否已设置
if [ -z "$SSH_HOST" ]; then
    echo "错误：未设置 SSH_HOST 环境变量。请设置为目标主机地址。"
    exit 1
fi

# 检查 SSH_KEY 是否已设置
if [ -z "$SSH_KEY" ]; then
    echo "错误：未设置 SSH_KEY 环境变量。请设置为密钥文件位置。"
    exit 1
fi

# 检查私钥是否存在
if [ ! -f "$SSH_KEY" ]; then
  echo "❌ 错误：未找到密钥文件 $SSH_KEY"
  exit 1
fi

# 设置私钥权限
cp "$SSH_KEY" "$SSH_KEY_DEST"
echo "✅ 已复制密钥到 $SSH_KEY_DEST"

# 设置正确权限
chmod 600 "$SSH_KEY_DEST"
echo "🔒 已设置密钥权限为 600"

# 修复归属（关键！tunneluser 必须拥有密钥）
chown tunneluser:tunneluser /home/tunneluser/.ssh -R
echo "👤 已修复 .ssh 目录归属为 tunneluser"

# 构建 SSH 目标
SSH_TARGET="${SSH_USER}@${SSH_HOST}"

# 输出配置信息（调试用）
echo "启动 SSH 动态端口转发..."
echo "目标: $SSH_TARGET:$SSH_PORT"
echo "本地 SOCKS 端口: $LOCAL_SOCKS_PORT"
echo "私钥: $SSH_KEY_DEST"

# 使用 autossh 建立稳定隧道
echo exec autossh -M 0 -N \
    -o "ServerAliveInterval $REMOTE_HOST_ALIVE_INTERVAL" \
    -o "ServerAliveCountMax 3" \
    -o "StrictHostKeyChecking no" \
    -o "ExitOnForwardFailure yes" \
    -i "$SSH_KEY_DEST" \
    -D "0.0.0.0:$LOCAL_SOCKS_PORT" \
    -p "$SSH_PORT" \
    "$SSH_TARGET"

exec autossh -M 0 -N \
    -o "ServerAliveInterval $REMOTE_HOST_ALIVE_INTERVAL" \
    -o "ServerAliveCountMax 3" \
    -o "StrictHostKeyChecking no" \
    -o "ExitOnForwardFailure yes" \
    -i "$SSH_KEY_DEST" \
    -D "0.0.0.0:$LOCAL_SOCKS_PORT" \
    -p "$SSH_PORT" \
    "$SSH_TARGET"