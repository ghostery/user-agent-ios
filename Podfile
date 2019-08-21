platform :ios, '11.4'

project './Client.xcodeproj'

inhibit_all_warnings!
use_frameworks!

# Put common pods for the main app in here
def user_agent_pods
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'GCDWebServer', '~> 3.0', :modular_headers => true
  pod 'Fuzi', '~> 3.0.0', :modular_headers => true
end

target 'Cliqz' do
  user_agent_pods
end

target 'Lumen' do
  user_agent_pods
end

target 'Ghostery' do
  user_agent_pods
end

target 'ClientTests' do
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'GCDWebServer', '~> 3.0', :modular_headers => true
end

target 'Storage' do
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'Fuzi', '~> 3.0.0', :modular_headers => true
end

target 'ShareTo' do
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
  pod 'Fuzi', '~> 3.0.0', :modular_headers => true
end

target 'Shared' do
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
  pod 'SwiftLint'
end
