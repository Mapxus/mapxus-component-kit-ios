
Pod::Spec.new do |s|

  s.name         = "MapxusComponentKit"
  s.version      = "3.7.0"
  s.summary      = "Indoor map UI component"
  s.description  = <<-DESC
                   Standardized indoor map UI component.
                   DESC
  s.homepage     = "http://www.mapxus.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Mapxus" => "developer@maphive.io" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => 'https://github.com/MapxusSample/mapxus-component-kit-ios.git', :tag => "#{s.version}" }
  s.requires_arc = true
  s.module_name  = "MapxusComponentKit"
  s.vendored_frameworks = "MapxusComponentKit/MapxusComponentKit.framework"
  s.dependency "MapxusMapSDK", "3.7.0"

end