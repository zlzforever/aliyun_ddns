# 使用 alpine 基础镜像
FROM docker.1ms.run/alpine:latest

# 安装 cron
RUN apk add --no-cache dcron jq curl

# 创建日志文件并设置权限
RUN touch /var/log/cron.log /var/log/aliddns.log

COPY aliyun /usr/local/bin/aliyun

# 将 aliddns.sh 文件复制到容器中
COPY aliddns.sh /aliddns.sh


# 添加定时任务
RUN echo "*/1 * * * * /aliddns.sh >> /var/log/aliddns.log 2>&1" > /etc/crontabs/root

# 启动 cron 服务
CMD ["crond", "-f", "-d", "8"]