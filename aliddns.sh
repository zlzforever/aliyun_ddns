#!/bin/sh

# 配置参数

DOMAIN=$DNS_DOMAIN
RR=$DNS_RR
TYPE=$DNS_TYPE
TTL=$DNS_TTL

aliyun configure set --profile dnsProfile \
    --access-key-id $ACCESS_KEY_ID \
    --access-key-secret $ACCESS_KEY_SECRET \
    --region cn-hangzhou # 此区域对 DNS 无影响，但必须设置

# aliyun alidns DescribeDomainRecords --DomainName linhecao.cn --RRKeyWord test

GetIp() {
    echo $(curl -s 4.ipw.cn)
}

GetValueFromJson() {
    local json="$1"
    local query="$2"
    echo $json | jq -r $query
}

DescribeSubDomainRecords() {
    echo $(aliyun alidns DescribeDomainRecords --DomainName $DOMAIN --RRKeyWord $RR)
}

AddDomainRecord() {
    echo $(aliyun alidns AddDomainRecord --DomainName $DOMAIN --RR $RR --Type $TYPE --Value $1 --TTL $TTL)
}

UpdateDomainRecord() {
    echo $(aliyun alidns UpdateDomainRecord --RecordId $1 --RR $RR --Type $TYPE --Value $2 --TTL $TTL)
}

ResolveDomain() {
    echo "域名： $RR.$DOMAIN, 类型: $TYPE, TTL: $TTL"
    rslt=$(DescribeSubDomainRecords | grep TotalCount)
    if [ -z "$rslt" ]; then
        echo "未获取到阿里云查询结果"
        return 1
    fi
    upvalue=$(GetValueFromJson "$rslt" ".DomainRecords.Record[0].Value")
    echo "原指向： $upvalue"
    NEW_VALUE=$(GetIp)
    if [ -z "$NEW_VALUE" ]; then
        echo "新指向为空"
        return 1
    fi

    echo "新指向： $NEW_VALUE"

    if [ "$upvalue" = "$NEW_VALUE" ]; then
        echo "已正确解析， 无需更新"
    elif [ "$upvalue" = "null" ]; then
        echo "添加解析记录..."
        AddDomainRecord $NEW_VALUE
    elif [ -n "$upvalue" ]; then
        echo "更新解析记录..."
        recordId=$(GetValueFromJson "$rslt" ".DomainRecords.Record[0].RecordId")
        UpdateDomainRecord $recordId $NEW_VALUE
    else
        echo "添加解析记录..."
        AddDomainRecord $NEW_VALUE
    fi
}

ResolveDomain
