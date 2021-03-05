#!/bin/sh

#  AutoRun.sh
#  MapxusMapSDK
#
#  Created by chenghao guo on 2020/10/14.
#  Copyright © 2020 MAPHIVE TECHNOLOGY LIMITED. All rights reserved.

#
ENV=""
#
COM=""
# 手动使用本工具打包时，可以不传-d参数，使用本默认值
FRAMEWORK_ROOT_PATH="${PWD}/.."

# c: 公司，可选mapxus、landsd
# d: framework文件存放根目录
# e: 环境，可选test、prod
while getopts ":c:d:e:" opt
do
    case $opt in
        d)
        FRAMEWORK_ROOT_PATH=$OPTARG
        ;;
        e)
        if [ $OPTARG == "test" ]; then
            ENV="-test"
        fi
        ;;
        c)
        if [ $OPTARG == "landsd" ]; then
            COM="-landsd"
        fi
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done


XCCONFIG_FILE='BuildConfig/mapxus.prod.xcconfig'

if [[ -z $COM ]] && [[ -z $ENV ]]; then
    XCCONFIG_FILE='BuildConfig/mapxus.prod.xcconfig'

elif [[ -z $COM ]] && [[ $ENV == "-test" ]]; then
    XCCONFIG_FILE='BuildConfig/mapxus.test.xcconfig'

elif [[ $COM == "-landsd" ]] && [[ -z $ENV ]]; then
    XCCONFIG_FILE='BuildConfig/landsd.prod.xcconfig'

elif [[ $COM == "-landsd" ]] && [[ $ENV == "-test" ]]; then
    XCCONFIG_FILE='BuildConfig/landsd.test.xcconfig'

fi


FRAMEWORK_DIR="$FRAMEWORK_ROOT_PATH/mapxus-component-kit-ios/dynamic"
#目录如果不存在，则拉取github
if [ ! -d "${FRAMEWORK_DIR}" ]
then
  git clone https://github.com/Mapxus/mapxus-component-kit-ios.git "$FRAMEWORK_ROOT_PATH/mapxus-component-kit-ios"
fi

#打包并复制到目录
pod install
xcodebuild -workspace MapxusComponentKit.xcworkspace -scheme MapxusComponentKit-Universal POD_DIR="$FRAMEWORK_DIR" XCCONFIG_FILE="$XCCONFIG_FILE"
