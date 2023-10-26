#!/bin/sh

#  UploadCocoapods.sh
#  MapxusComponentKit
#
#  Created by chenghao guo on 2021/3/2.
#  Copyright © 2021 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.

############## 变量初始化 ##############

# nexus的域名
REPOSITORY_URL='https://nexus3.mapxus.com'
# nexus的库名
REPOSITORY_NAME='ios-sdk'
# 分发根的上级目录，手动使用本工具打包时，可以不传-d参数，使用本默认值
DISTRIBUTION_PARENT_PATH="${PWD}/.."
# 分发根目录
DISTRIBUTION_ROOT_PATH="/mapxus-component-kit-ios"
# 压缩文件名
ZIP_FILE='mapxus-component-kit-ios.zip'
# 密码文件
ENV_FILE='nexus.env'
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
        if [[ $OPTARG == "landsd" ]]; then
            COM="-landsd"
        elif [[ $OPTARG == "kawasaki" ]]; then
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
    
elif [[ $COM == "-landsd" ]]; then
    # nexus的域名
    REPOSITORY_URL='https://nexus3.mapxus.com'
    # nexus的库名
    REPOSITORY_NAME='ios-landsd-sdk'
    #
    DISTRIBUTION_PARENT_PATH="${DISTRIBUTION_PARENT_PATH}/sdk-landsd"
    # 分发根目录
    DISTRIBUTION_ROOT_PATH="/mapxus-component-kit-ios-landsd"
    # 压缩文件名
    ZIP_FILE='mapxus-component-kit-ios-landsd.zip'
    # 密码文件
    ENV_FILE='nexus.env'
    # cocoapods配置文件
    POSDSPEC_FILE='MapxusComponentKit-landsd.podspec'
    
elif [[ $COM == "-kawasaki" ]]; then
    # nexus的域名
    REPOSITORY_URL='https://nexus3.mapxus.co.jp'
    # nexus的库名
    REPOSITORY_NAME='ios-sdk'
    #
    DISTRIBUTION_PARENT_PATH="${DISTRIBUTION_PARENT_PATH}/sdk-jp"
    # 分发根目录
    DISTRIBUTION_ROOT_PATH="/mapxus-component-kit-ios-jp"
    # 压缩文件名
    ZIP_FILE='mapxus-component-kit-ios-jp.zip'
    # 密码文件
    ENV_FILE='nexus-jp.env'
    # cocoapods配置文件
    POSDSPEC_FILE='MapxusComponentKit-jp.podspec'
    
fi


############## 压缩 ##############

### 读取account和password
export $(xargs < "BuildConfig/${ENV_FILE}")

WORK_DIR="${DISTRIBUTION_PARENT_PATH}${DISTRIBUTION_ROOT_PATH}"

# 进入目录
cd ${WORK_DIR}

if [ -f "${ZIP_FILE}" ]; then
  rm -r "${ZIP_FILE}"
fi

# 打包压缩
zip -r ${ZIP_FILE} * -x '*.podspec' '*/.*'


############## 上传到nexus ##############

### 获取tag
VERSION=$(git describe --abbrev=0 --tags)

### 上传到nexus
curl -v -u $account:$password -X POST \
"$REPOSITORY_URL/service/rest/v1/components?repository=$REPOSITORY_NAME" \
-F "raw.directory=${VERSION}" \
-F "raw.asset1=@${ZIP_FILE}" \
-F "raw.asset1.filename=${ZIP_FILE}"

############## 上传Cocoapods ##############

pod trunk push ${POSDSPEC_FILE} --skip-tests --skip-import-validation --allow-warnings --verbose
