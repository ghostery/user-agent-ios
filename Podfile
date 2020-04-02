platform :ios, '11.4'
require_relative './node_modules/@react-native-community/cli-platform-ios/native_modules'

project './UserAgent.xcodeproj'
workspace 'UserAgent'

inhibit_all_warnings!
use_frameworks!

## How to use this file
# We first create methods for each pod, so we can use the exact same configuration for each installation of a pod.
# Then the individual targets are just lists of method calls (see bottom of the file).

## Definition for individual pods, or groups of pods
def xclogger
  pod 'XCGLogger', '~> 7.0.0',  :modular_headers => true
end

def fuzi
  pod 'Fuzi', '~> 3.0', :modular_headers => true
end

def sqlite
  pod 'sqlite3', '~> 3.27.2'
  pod 'SQLCipher', '~> 4.2'
end

def swiftyjson
  pod 'SwiftyJSON', '~> 5.0'
end

def snapkit
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
end

def sdwebimage
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
end

def gcdwebserver
  pod 'GCDWebServer', '~> 3.3'
end

def sentry
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
end

def swiftlint
  pod 'SwiftLint'
end

def react_native
  pod 'FBLazyVector', :path => "./node_modules/react-native/Libraries/FBLazyVector"
  pod 'FBReactNativeSpec', :path => "./node_modules/react-native/Libraries/FBReactNativeSpec"
  pod 'RCTRequired', :path => "./node_modules/react-native/Libraries/RCTRequired"
  pod 'RCTTypeSafety', :path => "./node_modules/react-native/Libraries/TypeSafety"
  pod 'React', :path => './node_modules/react-native/'
  pod 'React-Core', :path => './node_modules/react-native/'
  pod 'React-CoreModules', :path => './node_modules/react-native/React/CoreModules'
  pod 'React-Core/DevSupport', :path => './node_modules/react-native/'
  pod 'React-RCTActionSheet', :path => './node_modules/react-native/Libraries/ActionSheetIOS'
  pod 'React-RCTAnimation', :path => './node_modules/react-native/Libraries/NativeAnimation'
  pod 'React-RCTBlob', :path => './node_modules/react-native/Libraries/Blob'
  pod 'React-RCTImage', :path => './node_modules/react-native/Libraries/Image'
  pod 'React-RCTLinking', :path => './node_modules/react-native/Libraries/LinkingIOS'
  pod 'React-RCTNetwork', :path => './node_modules/react-native/Libraries/Network'
  pod 'React-RCTSettings', :path => './node_modules/react-native/Libraries/Settings'
  pod 'React-RCTText', :path => './node_modules/react-native/Libraries/Text'
  pod 'React-RCTVibration', :path => './node_modules/react-native/Libraries/Vibration'
  pod 'React-Core/RCTWebSocket', :path => './node_modules/react-native/'
  pod 'React-cxxreact', :path => './node_modules/react-native/ReactCommon/cxxreact'
  pod 'React-jsi', :path => './node_modules/react-native/ReactCommon/jsi'
  pod 'React-jsiexecutor', :path => './node_modules/react-native/ReactCommon/jsiexecutor'
  pod 'React-jsinspector', :path => './node_modules/react-native/ReactCommon/jsinspector'
  pod 'ReactCommon/callinvoker', :path => "./node_modules/react-native/ReactCommon"
  pod 'ReactCommon/turbomodule/core', :path => "./node_modules/react-native/ReactCommon"
  pod 'Yoga', :path => './node_modules/react-native/ReactCommon/yoga', :modular_headers => true
  pod 'DoubleConversion', :podspec => './node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
  pod 'glog', :podspec => './node_modules/react-native/third-party-podspecs/glog.podspec'
  pod 'Folly', :podspec => './node_modules/react-native/third-party-podspecs/Folly.podspec'

  pod 'RNSqlite2', :path => './node_modules/react-native-sqlite-2/ios/'
  pod 'RNFS', :path => './node_modules/react-native-fs'

  use_native_modules!
end

## Definitions for targets

def main_app
  snapkit
  sdwebimage
  swiftyjson
  fuzi
  xclogger
  react_native
  gcdwebserver
end

def extensions
  snapkit
  swiftyjson
  fuzi
end

target 'Cliqz' do
  main_app
end

target 'Ghostery' do
  main_app
end

target 'Storage' do
  snapkit
  sdwebimage
  swiftyjson
  fuzi
  xclogger
  sqlite

  target 'StorageTests' do
    inherit! :search_paths
  end
end

target 'ShareTo' do
  extensions
end

target 'OpenIn' do
  extensions
end

target 'StoragePerfTests' do

end

target 'SharedTests' do

end

target 'ClientTests' do
  snapkit
  sdwebimage
  sentry
  gcdwebserver
end

target 'Shared' do
  sdwebimage
  swiftyjson
  sentry
  swiftlint
  xclogger
end

target 'Today' do
  react_native
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
end
