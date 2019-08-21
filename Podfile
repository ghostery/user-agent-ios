platform :ios, '11.4'

project './Client.xcodeproj'

inhibit_all_warnings!

target 'Cliqz' do
  use_frameworks!
end

target 'Lumen' do
  use_frameworks!
end

target 'Ghostery' do
  use_frameworks!
end

target 'Shared' do
  use_frameworks!

  pod 'SnapKit', '~> 5.0.0'

  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
  pod 'SwiftLint'
end
