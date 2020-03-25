#!/bin/sh
# Passing target name as an argument.
TARGETNAME=$1
PROJECTPATH=$2

if [ -z "${PROJECTPATH}" ]; then
    echo "Project path is empty!"
    exit 1
fi

if [ -z "${TARGETNAME}" ]; then
    echo "Target name is empty!"
    exit 1
fi

# Configuration folder path
CONFIG_PATH=${PROJECTPATH}/Client/Configuration
BRAND_PATH=${PROJECTPATH}/Branding/${TARGETNAME}/Configuration

# Replacing Debug/AdHoc/Release xcconfig files according target
mkdir -p ${CONFIG_PATH}
cp -rf ${BRAND_PATH}/${TARGETNAME}Debug.xcconfig ${CONFIG_PATH}/Debug.xcconfig
cp -rf ${BRAND_PATH}/${TARGETNAME}AdHoc.xcconfig ${CONFIG_PATH}/AdHoc.xcconfig
cp -rf ${BRAND_PATH}/${TARGETNAME}Release.xcconfig ${CONFIG_PATH}/Release.xcconfig

# Entitlments folder path
SHARETO_ENTITLEMENTS_PATH=${PROJECTPATH}/Extensions/ShareTo/Entitlements
OPENIN_ENTITLEMENTS_PATH=${PROJECTPATH}/Extensions/OpenIn/Entitlements
TODAY_ENTITLEMENTS_PATH=${PROJECTPATH}/Extensions/Today/Entitlements

# Replacing ShareTo/OpenIn entitlement files according target
mkdir -p ${SHARETO_ENTITLEMENTS_PATH}
cp -rf ${BRAND_PATH}/Entitlements/ShareTo/${TARGETNAME}ShareTo.entitlements ${SHARETO_ENTITLEMENTS_PATH}/ShareTo.entitlements
cp -rf ${BRAND_PATH}/Entitlements/ShareTo/${TARGETNAME}ShareToAdHoc.entitlements ${SHARETO_ENTITLEMENTS_PATH}/ShareToAdHoc.entitlements
cp -rf ${BRAND_PATH}/Entitlements/ShareTo/${TARGETNAME}ShareToDebug.entitlements ${SHARETO_ENTITLEMENTS_PATH}/ShareToDebug.entitlements

mkdir -p ${OPENIN_ENTITLEMENTS_PATH}
cp -rf ${BRAND_PATH}/Entitlements/OpenIn/${TARGETNAME}OpenIn.entitlements ${OPENIN_ENTITLEMENTS_PATH}/OpenIn.entitlements
cp -rf ${BRAND_PATH}/Entitlements/OpenIn/${TARGETNAME}OpenInAdHoc.entitlements ${OPENIN_ENTITLEMENTS_PATH}/OpenInAdHoc.entitlements
cp -rf ${BRAND_PATH}/Entitlements/OpenIn/${TARGETNAME}OpenInDebug.entitlements ${OPENIN_ENTITLEMENTS_PATH}/OpenInDebug.entitlements

mkdir -p ${TODAY_ENTITLEMENTS_PATH}
cp -rf ${BRAND_PATH}/Entitlements/Today/${TARGETNAME}Today.entitlements ${TODAY_ENTITLEMENTS_PATH}/Today.entitlements
cp -rf ${BRAND_PATH}/Entitlements/Today/${TARGETNAME}TodayAdHoc.entitlements ${TODAY_ENTITLEMENTS_PATH}/TodayAdHoc.entitlements
cp -rf ${BRAND_PATH}/Entitlements/Today/${TARGETNAME}TodayDebug.entitlements ${TODAY_ENTITLEMENTS_PATH}/TodayDebug.entitlements

# ShareTo folder path
SHARE_TO_PATH=${PROJECTPATH}/Extensions/ShareTo

# Replacing ShareTo assets according target
rm -rf ${SHARE_TO_PATH}/ShareTo.xcassets
cp -rf ${BRAND_PATH}/Assets/ShareTo.xcassets ${SHARE_TO_PATH}/

# OpenIn folder path
OPEN_IN_PATH=${PROJECTPATH}/Extensions/OpenIn

# Replacing OpenIn assets according target
rm -rf ${OPEN_IN_PATH}/OpenIn.xcassets
cp -rf ${BRAND_PATH}/Assets/OpenIn.xcassets ${OPEN_IN_PATH}/

# Replacing OpenIn assets and InfoPlist.strings according target
mkdir -p ${OPEN_IN_PATH}/de.lproj
mkdir -p ${OPEN_IN_PATH}/en.lproj
cp -rf ${BRAND_PATH}/InfoPlists/OpenIn/de.lproj/InfoPlist.strings ${OPEN_IN_PATH}/de.lproj/InfoPlist.strings
cp -rf ${BRAND_PATH}/InfoPlists/OpenIn/en.lproj/InfoPlist.strings ${OPEN_IN_PATH}/en.lproj/InfoPlist.strings

# Today folder path
TODAY_PATH=${PROJECTPATH}/Extensions/Today

# Replacing OpenIn assets and InfoPlist.strings according target
mkdir -p ${TODAY_PATH}/de.lproj
mkdir -p ${TODAY_PATH}/en.lproj
cp -rf ${BRAND_PATH}/InfoPlists/Today/de.lproj/InfoPlist.strings ${TODAY_PATH}/de.lproj/InfoPlist.strings
cp -rf ${BRAND_PATH}/InfoPlists/Today/en.lproj/InfoPlist.strings ${TODAY_PATH}/en.lproj/InfoPlist.strings

# Siri folder path
SIRI_PATH=${PROJECTPATH}/Extensions/Siri

# Replacing Siri localizations according target
mkdir -p ${SIRI_PATH}/de.lproj
mkdir -p ${SIRI_PATH}/en.lproj
cp -rf ${BRAND_PATH}/Siri/de.lproj/Intents.strings ${SIRI_PATH}/de.lproj/Intents.strings
cp -rf ${BRAND_PATH}/Siri/en.lproj/Intents.strings ${SIRI_PATH}/en.lproj/Intents.strings
