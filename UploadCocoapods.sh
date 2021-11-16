#!/bin/sh

#  UploadCocoapods.sh
#  MapxusComponentKit
#
#  Created by chenghao guo on 2021/3/2.
#  Copyright © 2021 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.

############## 变量初始化 ##############

# azure的分享名
SHARE_NAME='com-mapxus-iossdk'
# 分发根的上级目录，手动使用本工具打包时，可以不传-d参数，使用本默认值
DISTRIBUTION_PARENT_PATH="${PWD}/.."
# 分发根目录
DISTRIBUTION_ROOT_PATH="/mapxus-component-kit-ios"
# 压缩文件名
ZIP_FILE='mapxus-component-kit-ios.zip'
# 密码文件
ENV_FILE='azure.env'
# cocoapods配置文件
POSDSPEC_FILE='MapxusComponentKit.podspec'



############## 参数获取 ##############

# c: 公司，可选mapxus、landsd、kawasaki
# d: framework文件存放根目录
while getopts ":c:d:" opt
do
    case $opt in
        d)
        DISTRIBUTION_PARENT_PATH=$OPTARG
        ;;
        c)
        if [[ $OPTARG == "kawasaki" ]]; then
            COM="-kawasaki"
        fi
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done


############## 更新变量 ##############

if [[ -z $COM ]]; then
    echo "COM=mapxus"
elif [[ $COM == "-kawasaki" ]]; then
    DISTRIBUTION_PARENT_PATH="${DISTRIBUTION_PARENT_PATH}/sdk-jp"
    # 分发根目录
    DISTRIBUTION_ROOT_PATH="/mapxus-component-kit-ios-jp"
    # 压缩文件名
    ZIP_FILE='mapxus-component-kit-ios-jp.zip'
    # 密码文件
    ENV_FILE='azure-jp.env'
    # cocoapods配置文件
    POSDSPEC_FILE='MapxusComponentKit-jp.podspec'
    
fi


############## 压缩 ##############

### 读取key和name
export $(xargs < "BuildConfig/${ENV_FILE}")

WORK_DIR="${DISTRIBUTION_PARENT_PATH}${DISTRIBUTION_ROOT_PATH}"

# 进入目录
cd ${WORK_DIR}

if [ -f "${ZIP_FILE}" ]; then
  rm -r "${ZIP_FILE}"
fi

# 打包压缩
zip -r ${ZIP_FILE} * -x '*.podspec' '*/.*'


############## 上传azure ##############

### 获取tag
VERSION=$(git describe --abbrev=0 --tags)

### create version directory
az storage directory create \
--share-name ${SHARE_NAME} \
--account-key ${accountKey} \
--account-name ${accountName} \
--name ${VERSION}

### upload file
az storage file upload \
--share-name ${SHARE_NAME} \
--account-key ${accountKey} \
--account-name ${accountName} \
--path "${VERSION}/${ZIP_FILE}" \
--source ${ZIP_FILE}


############## 上传Cocoapods ##############

pod trunk push ${POSDSPEC_FILE} --allow-warnings --verbose
