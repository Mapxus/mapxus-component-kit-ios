# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

source 'https://nexus3.mapxus.com/repository/cocoapods-proxy/'

target 'MapxusComponentKit' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # Pods for MapxusComponentKit
  pod 'MapxusBaseSDK', :path => '../mapxus-base-sdk-ios'
  pod 'MapxusMapSDK', :path => '../mapxus-map-sdk-ios'
  
  target 'MapxusComponentKitTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
end

#bitcode enable
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
