Pod::Spec.new do |s|
  s.name             = "rnPage"
  s.version          = "1.0.0"
  s.summary          = "a Page Category"
  s.description      = "this is a Page Category like tabbar on top"
  s.homepage         = "https://github.com/tacrednow/rnPage"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "潘佳文" => "tacrednow@outlook.com" }
  s.source           = { :git => "https://github.com/tacrednow/rnPage.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/NAME'

  s.platform     = :ios, '8.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'rnPage/*'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'

end