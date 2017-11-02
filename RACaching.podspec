#
# Be sure to run `pod lib lint RACaching.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RACaching'
  s.version          = '0.1.0'
  s.summary          = 'RACaching is a library for cache remote resources (images, JSON, XML, etc) in-memory'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The purpose of the library is to abstract the downloading (images, pdf, zip, etc) and caching of remote resources (images, JSON, XML, etc) in-memory.
                       DESC

  s.homepage         = 'https://github.com/rallahaseh/RACaching'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rallahaseh' => 'rallahaseh@gmail.com' }
  s.source           = { :git => 'https://github.com/rallahaseh/RACaching.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/rallahaseh'

  s.ios.deployment_target = '8.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

  s.source_files = 'RACaching/Classes/**/*'

end
