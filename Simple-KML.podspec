Pod::Spec.new do |s|

  s.name         = "Simple-KML"
  s.version      = "0.1.0"
  s.summary      = "Simple KML is a simple & lightweight parsing library for KML written in Objective-C for the iOS platform."

  s.homepage     = "https://github.com/mapbox/Simple-KML"
  s.license      = { :file => "LICENSE.MD" }
  s.author       = { "MapBox" => "ios@mapbox.com" }
  s.platform     = :ios, "5.0"

  s.source       = { :git => 'https://github.com/mapbox/Simple-KML.git' }
  s.xcconfig     = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  s.dependency 'TouchXML'
  s.dependency 'objective-zip'
  
  s.ios.framework = "UIKit"
  s.library = 'xml2'
  s.source_files = "source/*.{h,m}"
  s.requires_arc = true

end
