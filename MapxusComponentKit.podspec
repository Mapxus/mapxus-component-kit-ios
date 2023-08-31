
Pod::Spec.new do |s|


  version = '6.2.0'

  s.name         = 'MapxusComponentKit'
  s.version      = version

  s.summary      = 'Indoor map UI component'
  s.description  = 'Standardized indoor map UI component.'
  s.homepage     = 'https://www.mapxus.com'
  s.license      = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  s.author       = { 'Mapxus' => 'developer@maphive.io' }

  s.platform     = :ios, '9.0'

  s.source       = { :http => "https://nexus3.mapxus.com/repository/ios-sdk/#{version.to_s}/mapxus-component-kit-ios.zip", :flatten => true }

  s.requires_arc = true

  s.module_name  = 'MapxusComponentKit'
  s.vendored_frameworks = 'dynamic/MapxusComponentKit.xcframework'

  s.dependency "MapxusMapSDK", version


end