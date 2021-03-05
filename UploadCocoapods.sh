#!/bin/sh

#  UploadCocoapods.sh
#  MapxusComponentKit
#
#  Created by chenghao guo on 2021/3/4.
#  Copyright © 2021 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.

# 手动使用本工具打包时，可以不传-d参数，使用本默认值
FRAMEWORK_ROOT_PATH="${PWD}/.."

# c: 公司，可选mapxus、landsd
# d: framework文件存放根目录
# e: 环境，可选test、prod
while getopts ":d:" opt
do
    case $opt in
        d)
        FRAMEWORK_ROOT_PATH=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

# 定义
WORK_DIR="$FRAMEWORK_ROOT_PATH/mapxus-component-kit-ios"

zipFile=mapxus-component-kit-ios.zip

shareName=com-mapxus-iossdk

podspecFile=MapxusComponentKit.podspec

# 进入目录
cd $WORK_DIR

# 打包压缩
zip -r $zipFile * -x '*.podspec' '*/.*'

# 上传
### 获取tag
version=$(git describe --abbrev=0 --tags)

### 读取key和name
export $(xargs < BuildConfig/azure.env)

### create version directory
az storage directory create \
--share-name $shareName \
--account-key $accountKey \
--account-name $accountName \
--name $version

### upload file
az storage file upload \
--share-name $shareName \
--account-key $accountKey \
--account-name $accountName \
--path $version \
--source $zipFile

# 上传Cocoapods
pod trunk push $podspecFile --allow-warnings --verbose
