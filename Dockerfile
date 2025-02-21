# 使用 alpine 基础镜像
FROM alpine:latest

# 安装 cron
RUN apk add --no-cache jq curl

# 安装 aliyun cli
COPY aliyun /usr/local/bin/aliyun

# 将 aliddns.sh 文件复制到容器中
ADD aliddns.sh /aliddns.sh
RUN chmod + /aliddns.sh

# 添加定时任务
RUN touch crontab.tmp \
    && echo "*/1 * * * * /aliddns.sh >> /var/log/aliddns.log 2>&1" > crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

# 启动 cron 服务
CMD ["/usr/sbin/crond", "-f", "-d", "0"]
