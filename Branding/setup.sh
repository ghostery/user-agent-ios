#!/bin/sh
# Passing target name as an argument.
TARGETNAME=$1

# Configuration folder path
CONFIG_PATH=${PROJECT_DIR}/Client/Configuration
BRAND_PATH=${PROJECT_DIR}/Branding/${TARGETNAME}/Configuration

# Replacing Debug/AdHoc/Release xcconfig files according target
mkdir -p ${CONFIG_PATH}
cp -rf ${BRAND_PATH}/${TARGETNAME}Debug.xcconfig ${CONFIG_PATH}/Debug.xcconfig
cp -rf ${BRAND_PATH}/${TARGETNAME}AdHoc.xcconfig ${CONFIG_PATH}/AdHoc.xcconfig
cp -rf ${BRAND_PATH}/${TARGETNAME}Release.xcconfig ${CONFIG_PATH}/Release.xcconfig

# Entitlments folder path
ENTITLEMENTS_PATH=${PROJECT_DIR}/Extensions/Entitlements

# Replacing ShareTo/OpenIn entitlement files according target
mkdir -p ${ENTITLEMENTS_PATH}
cp -rf ${BRAND_PATH}/Entitlements/${TARGETNAME}ShareTo.entitlements ${ENTITLEMENTS_PATH}/ShareTo.entitlements
cp -rf ${BRAND_PATH}/Entitlements/${TARGETNAME}OpenIn.entitlements ${ENTITLEMENTS_PATH}/OpenIn.entitlements

# ShareTo folder path
SHARE_TO_PATH=${PROJECT_DIR}/Extensions/ShareTo

# Replacing ShareTo assets according target
rm -rf ${SHARE_TO_PATH}/ShareTo.xcassets
cp -rf ${BRAND_PATH}/Assets/ShareTo.xcassets ${SHARE_TO_PATH}/

# OpenIn folder path
OPEN_IN_PATH=${PROJECT_DIR}/Extensions/OpenIn

# Replacing OpenIn assets according target
rm -rf ${OPEN_IN_PATH}/OpenIn.xcassets
cp -rf ${BRAND_PATH}/Assets/OpenIn.xcassets ${OPEN_IN_PATH}/

# Replacing OpenIn assets and InfoPlist.strings according target
mkdir -p ${OPEN_IN_PATH}/de.lproj
mkdir -p ${OPEN_IN_PATH}/en.lproj
cp -rf ${BRAND_PATH}/InfoPlists/de.lproj/InfoPlist.strings ${OPEN_IN_PATH}/de.lproj/InfoPlist.strings
cp -rf ${BRAND_PATH}/InfoPlists/en.lproj/InfoPlist.strings ${OPEN_IN_PATH}/en.lproj/InfoPlist.strings

