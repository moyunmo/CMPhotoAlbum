#
# Be sure to run `pod lib lint CMPhotoAlbum.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CMPhotoAlbum'
  s.version          = '1.0.0'
  s.summary          = 'A simple component for replacing a system album.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple component for replacing a system album. 一个简单的替换系统相册的组件
                       DESC

  s.homepage         = 'https://github.com/moyunmo/CMPhotoAlbum'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'momo605654602@gmail.com' => 'moyunmo@hotmail.com' }
  s.source           = { :git => 'https://github.com/moyunmo/CMPhotoAlbum.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CMPhotoAlbum/Classes/**/*'
  s.resources    = ['CMPhotoAlbum/Assets/*.{bundle,xib}']

  # s.resource_bundles = {
  #   'CMPhotoAlbum' => ['CMPhotoAlbum/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
