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
def flipper
  flipperkit_version = '~> 0.35.0'

  pod 'FlipperKit', flipperkit_version, :configuration => 'Debug'
  # Layout and network plugins are not yet supported for swift projects
  pod 'FlipperKit/FlipperKitLayoutComponentKitSupport', flipperkit_version, :configuration => 'Debug'
  pod 'FlipperKit/SKIOSNetworkPlugin', flipperkit_version, :configuration => 'Debug'
  pod 'FlipperKit/FlipperKitUserDefaultsPlugin', flipperkit_version, :configuration => 'Debug'
  pod 'FlipperKit/FlipperKitReactPlugin', flipperkit_version, :configuration => 'Debug'
end

def flipper_post_install(installer)
  installer.pods_project.targets.each do |target|
    if target.name == 'YogaKit'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.1'
      end
    end
  end

  file_name = Dir.glob("*.xcodeproj")[0]
  app_project = Xcodeproj::Project.open(file_name)
  app_project.native_targets.each do |target|
      target.build_configurations.each do |config|
        if (config.build_settings['OTHER_SWIFT_FLAGS'])
          unless config.build_settings['OTHER_SWIFT_FLAGS'].include? '-DFB_SONARKIT_ENABLED'
            puts 'Adding -DFB_SONARKIT_ENABLED ...'
            swift_flags = config.build_settings['OTHER_SWIFT_FLAGS']
            if swift_flags.split.last != '-Xcc'
              config.build_settings['OTHER_SWIFT_FLAGS'] << ' -Xcc'
            end
            config.build_settings['OTHER_SWIFT_FLAGS'] << ' -DFB_SONARKIT_ENABLED'
          end
        else
          puts 'OTHER_SWIFT_FLAGS does not exist thus assigning it to `$(inherited) -Xcc -DFB_SONARKIT_ENABLED`'
          config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -Xcc -DFB_SONARKIT_ENABLED'
        end
        app_project.save
      end
    end
    installer.pods_project.save
end

def flipper_pre_install(installer)
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}

  static_framework = ['FlipperKit', 'Flipper', 'Flipper-Folly',
    'CocoaAsyncSocket', 'ComponentKit', 'Flipper-DoubleConversion',
    'Flipper-Glog', 'Flipper-PeerTalk', 'Flipper-RSocket', 'YogaKit',
    'CocoaLibEvent', 'OpenSSL-Universal', 'boost-for-react-native']

  installer.pod_targets.each do |pod|
    if static_framework.include?(pod.name)
      def pod.build_type;
        Pod::BuildType.static_library
      end
    end
  end
end

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
  flipper
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

pre_install do |installer|
  flipper_pre_install(installer)
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end

  flipper_post_install(installer)
end
