require_relative './node_modules/@react-native-community/cli-platform-ios/native_modules'

platform :ios, '11.4'

project './Client.xcodeproj'
workspace 'UserAgent'

inhibit_all_warnings!

# use_frameworks! Does not work with ReactNative 0.60 https://github.com/facebook/react-native/issues/25349#issuecomment-519014463
# use_frameworks!

def react_native
  pod 'React', :path => './node_modules/react-native/'
  pod 'React-Core', :path => './node_modules/react-native/React'
  pod 'React-DevSupport', :path => './node_modules/react-native/React'
  pod 'React-RCTActionSheet', :path => './node_modules/react-native/Libraries/ActionSheetIOS'
  pod 'React-RCTAnimation', :path => './node_modules/react-native/Libraries/NativeAnimation'
  pod 'React-RCTBlob', :path => './node_modules/react-native/Libraries/Blob'
  pod 'React-RCTImage', :path => './node_modules/react-native/Libraries/Image'
  pod 'React-RCTLinking', :path => './node_modules/react-native/Libraries/LinkingIOS'
  pod 'React-RCTNetwork', :path => './node_modules/react-native/Libraries/Network'
  pod 'React-RCTSettings', :path => './node_modules/react-native/Libraries/Settings'
  pod 'React-RCTText', :path => './node_modules/react-native/Libraries/Text'
  pod 'React-RCTVibration', :path => './node_modules/react-native/Libraries/Vibration'
  pod 'React-RCTWebSocket', :path => './node_modules/react-native/Libraries/WebSocket'

  pod 'React-cxxreact', :path => './node_modules/react-native/ReactCommon/cxxreact'
  pod 'React-jsi', :path => './node_modules/react-native/ReactCommon/jsi'
  pod 'React-jsiexecutor', :path => './node_modules/react-native/ReactCommon/jsiexecutor'
  pod 'React-jsinspector', :path => './node_modules/react-native/ReactCommon/jsinspector'
  pod 'yoga', :path => './node_modules/react-native/ReactCommon/yoga'

  pod 'DoubleConversion', :podspec => './node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
  pod 'glog', :podspec => './node_modules/react-native/third-party-podspecs/glog.podspec'
  pod 'Folly', :podspec => './node_modules/react-native/third-party-podspecs/Folly.podspec'

  use_native_modules! '.'
end

def shared
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'SwiftyJSON', '~> 5.0'
end

target 'Cliqz' do
  shared
  react_native
end

target 'Lumen' do
  shared
  react_native
end

target 'Ghostery' do
  shared
  react_native
end

target 'Storage' do
  shared
end

target 'StorageTests' do
  pod 'SwiftyJSON', '~> 5.0'
end

target 'ShareTo' do
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'SwiftyJSON', '~> 5.0'
end

target 'ClientTests' do
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
end

target 'Shared' do
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'SwiftyJSON', '~> 5.0'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
  pod 'SwiftLint'
end
