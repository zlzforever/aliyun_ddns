# aliyun_ddns

## 打包 docker 镜像

### 下载

执行下载脚本， 下载 aliyun cli 到本地目录
```
sh download_aliyun_cli.sh
```

### 打包

```
docker build . --file Dockerfile --tag zlzforever/aliyun_ddns
```

## 部署

```
docker run -d aliyun_ddns_domain1 \
    -e ACCESS_KEY_ID= \
    -e ACCESS_KEY_SECRET= \
    -e DNS_DOMAIN= \
    -e DNS_RR= \
    -e DNS_TYPE= \
    -e DNS_TTL=600 \
    zlzforever/aliyun_ddns
```
