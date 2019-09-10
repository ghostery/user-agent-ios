platform :ios, '11.4'

project './Client.xcodeproj'
workspace 'UserAgent'

inhibit_all_warnings!
use_frameworks!

## How to use this file
# We first create methods for each pod, so we can use the exact same configuration for each installation of a pod.
# Then the individual targets are just lists of method calls (see bottom of the file).

## Definition for individual pods, or groups of pods
def swiftkeychainwrapper
  pod 'SwiftKeychainWrapper', '~> 3.2', :modular_headers => true
end

def xclogger
  pod 'XCGLogger', '~> 7.0.0',  :modular_headers => true
end

def fuzi
  pod 'Fuzi', '~> 3.0', :modular_headers => true
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

## Definitions for targets

def main_app
  snapkit
  sdwebimage
  swiftyjson
  fuzi
  xclogger
  swiftkeychainwrapper
  react_native
  gcdwebserver
end

def share_to
  snapkit
  swiftyjson
  fuzi
  swiftkeychainwrapper
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
  swiftkeychainwrapper
end

target 'StorageTests' do
  swiftyjson
end

target 'CliqzShareTo' do
  share_to
end

target 'GhosteryShareTo' do
  share_to
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
  swiftkeychainwrapper
end
