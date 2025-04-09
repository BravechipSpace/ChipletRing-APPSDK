#
# Be sure to run `pod lib lint Rings-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Rings-SDK'
  s.version          = '0.1.8'
  s.summary          = 'ring SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This is a sdk for the ios platform specifically for the Yongxin ring
                       DESC

  s.homepage         = 'https://github.com/wcb133/Rings-SDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weicb' => '1047732873@qq.com' }
  s.source           = { :git => 'https://github.com/wcb133/Rings-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.source_files = 'Rings-SDK/Classes/*'

  s.vendored_frameworks = 'RingsSDK.framework'
end
