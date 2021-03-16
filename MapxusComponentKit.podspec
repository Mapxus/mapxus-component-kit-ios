
Pod::Spec.new do |s|


  version = '3.20.1'

  s.name         = 'MapxusComponentKit'
  s.version      = version

  s.summary      = 'Indoor map UI component'
  s.description  = 'Standardized indoor map UI component.'
  s.homepage     = 'http://www.mapxus.com'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Mapxus' => 'developer@maphive.io' }

  s.platform     = :ios, '9.0'

  s.source       = { :http => "https://ios-sdk.mapxus.com/#{version.to_s}/mapxus-component-kit-ios.zip", :flatten => true }

  s.requires_arc = true

  s.module_name  = 'MapxusComponentKit'
  s.vendored_frameworks = 'dynamic/MapxusComponentKit.framework'

  s.dependency "MapxusMapSDK", version


end