platform :ios, '11.4'

project './Client.xcodeproj'
workspace 'UserAgent'

inhibit_all_warnings!

use_frameworks!

def react_native
  react_path = './node_modules/react-native'
  yoga_path = File.join(react_path, 'ReactCommon/yoga')
  folly_path = File.join(react_path, 'third-party-podspecs/Folly.podspec')

  pod 'Folly', :podspec => folly_path
  pod 'React', :path => './node_modules/react-native', :subspecs => [
    'Core',
    'DevSupport',
    'CxxBridge',
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket',
    'RCTImage',
    'RCTAnimation',
  ]
  pod 'yoga', :path => yoga_path

  pod 'RNSqlite2', :path => './node_modules/react-native-sqlite-2/ios/'
  pod 'RNFS', :path => './node_modules/react-native-fs'
end

def shared
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'SwiftyJSON', '~> 5.0'
  pod 'Fuzi', '~> 3.0', :modular_headers => true
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
  pod 'Fuzi', '~> 3.0', :modular_headers => true
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
