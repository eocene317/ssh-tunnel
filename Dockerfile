# 使用轻量级 Alpine 镜像
FROM alpine:3.19

# 维护者信息（可选）
LABEL maintainer="zerowang317@gmail.com"

# 安装 autossh、openssh-client 和必要的工具
RUN apk add --no-cache openssh-client autossh bash

# 创建非 root 用户（推荐）
RUN adduser -D tunneluser && \
    mkdir -p /home/tunneluser/.ssh && \
    chown -R tunneluser:tunneluser /home/tunneluser/.ssh && \
    chmod 700 /home/tunneluser/.ssh

# 复制配置文件和启动脚本
COPY entrypoint.sh /entrypoint.sh

# 设置权限
RUN chmod +x /entrypoint.sh && \
    chown tunneluser:tunneluser /entrypoint.sh

# 暴露本地 SOCKS 端口（可选，仅说明用途）
EXPOSE 4402

# 切换到非 root 用户
USER tunneluser

# 启动脚本
ENTRYPOINT ["/entrypoint.sh"]