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
PODSPEC_FILE='MapxusComponentKit.podspec'
# Package配置文件
PACKAGE_FILE='Package.swift'
# changelog文件名
CHANGELOG_FILE='CHANGELOG.md'
# 库名
TARGET_NAME='MapxusBaseSDK'


# 从changelog获取版本号
VERSION=$(sed -n 's/^## v\([^ ]*\) .*$/\1/p' $CHANGELOG_FILE)
echo "version: $VERSION"
# changelog内容
CHANGELOG_CONTENT=$(cat "$CHANGELOG_FILE")



############## 参数获取 ##############

# c: 公司，可选mapxus、landsd、kawasaki
# d: framework文件存放根目录
while getopts ":c:d" opt
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


############## 根据输入更新变量 ##############

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
    PODSPEC_FILE='MapxusComponentKit-landsd.podspec'
    
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
    PODSPEC_FILE='MapxusComponentKit-jp.podspec'
    
fi


############## 压缩 ##############

### 读取account和password
export $(xargs < "BuildConfig/${ENV_FILE}")

# 进入目录
WORK_DIR="${DISTRIBUTION_PARENT_PATH}${DISTRIBUTION_ROOT_PATH}"
cd ${WORK_DIR}

# 删除旧包
if [ -f "${ZIP_FILE}" ]; then
  rm -r "${ZIP_FILE}"
fi

# 打包压缩
zip -r ${ZIP_FILE} * -x '*.podspec' 'Package.swift' '*/.*'



############## 修改配置文件内容 ##############

### 获取checksum
checksum=$(swift package compute-checksum ${ZIP_FILE})
### 替换checksum
perl -i -pe 'BEGIN { $/ = undef; } s/(binaryTarget\(\s*name:\s*"MapxusBaseSDK",.*?checksum:\s*)"[^"]*"/$1"'$checksum'"/sg' $PACKAGE_FILE
### 替换package版本号
sed -i '' "s/let version = \".*\"/let version = \"$VERSION\"/g" $PACKAGE_FILE
### 替换podspec版本号
sed -i '' "s/version = \'.*\'/version = \'$VERSION\'/g" $PODSPEC_FILE



############## 保存修改到git ##############

# 提交修改
echo "提交修改..."
git add .
git commit -m "$CHANGELOG_CONTENT"

# 推送修改
echo "推送修改..."
git push

# 打tag
echo "打tag..."
git tag $VERSION
git push origin $VERSION



############## 上传到nexus ##############

curl -v -u $account:$password -X POST \
"$REPOSITORY_URL/service/rest/v1/components?repository=$REPOSITORY_NAME" \
-F "raw.directory=${VERSION}" \
-F "raw.asset1=@${ZIP_FILE}" \
-F "raw.asset1.filename=${ZIP_FILE}"



############## 上传Cocoapods ##############

pod repo push mapxus ${PODSPEC_FILE} --skip-tests --skip-import-validation --allow-warnings --verbose

echo "完成！"
