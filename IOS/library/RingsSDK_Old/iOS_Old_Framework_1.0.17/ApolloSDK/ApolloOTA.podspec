#
# Be sure to run `pod lib lint ApolloOTA.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ApolloOTA'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ApolloOTA.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/qq432591/ApolloOTA'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qq432591' => 'dtl432591@gmail.com' }
  s.source           = { :git => 'https://github.com/qq432591/ApolloOTA.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'amOtaApi.framework'
  s.public_header_files = 'amOtaApi.framework/Headers/*.h'

  s.vendored_frameworks = 'amOtaApi.framework'

  s.frameworks = 'CoreBluetooth','Foundation'
  
  # s.resource_bundles = {
  #   'ApolloOTA' => ['ApolloOTA/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
