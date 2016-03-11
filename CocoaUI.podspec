Pod::Spec.new do |s|
  s.name         = "CocoaUI"
  s.version      = "1.2.5"
  s.summary      = "Build adaptive UI for iOS Apps with Flow-Layout mechanism and CSS properties."

  s.homepage     = "http://www.cocoaui.com"

  s.license      = "New BSD License."
 
  s.author             = { "ideawu" => "ideawu@cocoaui.com" }
  #s.social_media_url   = "http://www.cocoaui.com"

  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  # s.source       = { :git => "https://github.com/ideawu/cocoaui.git", :tag => s.version }
  s.source       = { :git => "https://github.com/ideawu/cocoaui.git" }

  s.source_files  = "IKit/*.{h,m}", "IKit/*/*.{m,h}", "IObj/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"

  #s.public_header_files = "IKit/*.{h}"
  s.prefix_header_contents = <<-EOS
  #ifndef IKit_PrefixHeader_pch
  #define IKit_PrefixHeader_pch

  #define VER_NUM  "1.2.5"

  #ifdef DEBUG
  # define VERSION  VER_NUM "(for development only)"
  # define log_trace(...) NSLog(__VA_ARGS__)
  # define log_debug(...) NSLog(__VA_ARGS__)
  # define log_info(...) NSLog(__VA_ARGS__)
  #else
  # define VERSION  VER_NUM "(for production)"
  #if 1
  # define log_trace(...)
  # define log_debug(...)
  #else
  # define log_trace(...) NSLog(__VA_ARGS__)
  # define log_debug(...) NSLog(__VA_ARGS__)
  #endif
  # define log_info(...) NSLog(__VA_ARGS__)
  #endif

  #endif
  EOS

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  s.frameworks = "Foundation", "UIKit" 

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  s.library = "xml2"

  # s.requires_arc = true

  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"
  s.module_name = 'CocoaUI' 
end
