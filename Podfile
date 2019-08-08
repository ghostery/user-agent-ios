platform :ios, '11.4'
inhibit_all_warnings!

target 'Client' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Client

  target 'ClientTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Shared' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
end