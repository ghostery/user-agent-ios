#!/bin/sh

CONFIG_PATH=${PROJECT_DIR}/Client/Configuration/

cp -rf ${CONFIG_PATH}/Cliqz/CliqzDebug.xcconfig ${CONFIG_PATH}/Debug.xcconfig
cp -rf ${CONFIG_PATH}/Cliqz/CliqzAdHoc.xcconfig ${CONFIG_PATH}/AdHoc.xcconfig
cp -rf ${CONFIG_PATH}/Cliqz/CliqzRelease.xcconfig ${CONFIG_PATH}/Release.xcconfig
