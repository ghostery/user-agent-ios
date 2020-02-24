#!/bin/sh
TARGETNAME=$1

CONFIG_PATH=${PROJECT_DIR}/Client/Configuration

cp -rf ${CONFIG_PATH}/${TARGETNAME}/${TARGETNAME}Debug.xcconfig ${CONFIG_PATH}/Debug.xcconfig
cp -rf ${CONFIG_PATH}/${TARGETNAME}/${TARGETNAME}AdHoc.xcconfig ${CONFIG_PATH}/AdHoc.xcconfig
cp -rf ${CONFIG_PATH}/${TARGETNAME}/${TARGETNAME}Release.xcconfig ${CONFIG_PATH}/Release.xcconfig

ENTITLEMENTS_PATH=${PROJECT_DIR}/Extensions/Entitlements

cp -rf ${CONFIG_PATH}/${TARGETNAME}/Entitlements/${TARGETNAME}ShareTo.entitlements ${ENTITLEMENTS_PATH}/ShareTo.entitlements
cp -rf ${CONFIG_PATH}/${TARGETNAME}/Entitlements/${TARGETNAME}OpenIn.entitlements ${ENTITLEMENTS_PATH}/OpenIn.entitlements


SHARE_TO_PATH=${PROJECT_DIR}/Extensions/ShareTo

cp -rf ${CONFIG_PATH}/${TARGETNAME}/Assets/${TARGETNAME}ShareTo.xcassets ${SHARE_TO_PATH}/ShareTo.xcassets

OPEN_IN_PATH=${PROJECT_DIR}/Extensions/OpenIn

cp -rf ${CONFIG_PATH}/${TARGETNAME}/Assets/${TARGETNAME}OpenIn.xcassets ${OPEN_IN_PATH}/OpenIn.xcassets
cp -rf ${CONFIG_PATH}/${TARGETNAME}/InfoPlists/${TARGETNAME}OpenInde.lproj/InfoPlist.strings ${OPEN_IN_PATH}/de.lproj/InfoPlist.strings
cp -rf ${CONFIG_PATH}/${TARGETNAME}/InfoPlists/${TARGETNAME}OpenInen.lproj/InfoPlist.strings ${OPEN_IN_PATH}/en.lproj/InfoPlist.strings

