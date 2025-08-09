#!/bin/bash

# 默认值（可通过环境变量覆盖）
: ${SSH_HOST:="xxx.your-remote-host.com"}
: ${SSH_PORT:="22"}
: ${SSH_USER:="root"}
: ${SSH_KEY:="/home/tunneluser/.ssh/id_rsa"}
: ${LOCAL_SOCKS_PORT:="4402"}
: ${REMOTE_HOST_ALIVE_INTERVAL:=30}

# 检查私钥是否存在
if [ ! -f "$SSH_KEY" ]; then
    echo "错误：未找到 SSH 私钥文件 $SSH_KEY"
    echo "请确保将私钥挂载到容器中的 $SSH_KEY"
    exit 1
fi

# 设置私钥权限
chmod 600 "$SSH_KEY" || true

# 构建 SSH 目标
SSH_TARGET="${SSH_USER}@${SSH_HOST}"

# 输出配置信息（调试用）
echo "启动 SSH 动态端口转发..."
echo "目标: $SSH_TARGET:$SSH_PORT"
echo "本地 SOCKS 端口: $LOCAL_SOCKS_PORT"
echo "私钥: $SSH_KEY"

# 使用 autossh 建立稳定隧道
exec autossh -M 0 -N \
    -o "ServerAliveInterval $REMOTE_HOST_ALIVE_INTERVAL" \
    -o "ServerAliveCountMax 3" \
    -o "StrictHostKeyChecking no" \
    -o "ExitOnForwardFailure yes" \
    -i "$SSH_KEY" \
    -D "0.0.0.0:$LOCAL_SOCKS_PORT" \
    -p "$SSH_PORT" \
    "$SSH_TARGET"