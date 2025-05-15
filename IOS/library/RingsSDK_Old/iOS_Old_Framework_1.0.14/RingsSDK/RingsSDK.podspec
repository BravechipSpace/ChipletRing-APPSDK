Pod::Spec.new do |spec|
  spec.name         = "RingsSDK"
  spec.version      = '1.0.11'
  spec.summary      = 'ring SDK'
  spec.platform     = :ios
  spec.ios.deployment_target = '13.0'
  spec.description      = <<-DESC
  This is a sdk for the ios platform specifically for the Yongxin ring
                       DESC
  spec.homepage     = "https://github.com/Z-y-hu/ChipletRing-SDKCode-iOS"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "Carton" => "81851105+Z-y-hu@users.noreply.github.com" }
  spec.source       = { :git => "https://github.com/Z-y-hu/ChipletRing-SDKCode-iOS.git", :tag => "#{spec.version}" }

  # 指向实际源码
  # spec.source_files = 'RingsSDK/**/*.{h,m,swift,c}'
  spec.swift_version = '5.0'
  spec.requires_arc = true
  spec.frameworks = 'CoreBluetooth', 'Foundation'

  spec.source_files = 'RingsSDK.framework'
  spec.public_header_files = 'RingsSDK.framework/Headers/*.h'

  spec.vendored_frameworks = 'RingsSDK.framework'

  # # 三方依赖
  # spec.dependency 'RxSwift', '~> 6.8.0'
  # spec.dependency 'RxRelay', '~> 6.8.0'
  # spec.dependency 'Alamofire', '~> 5.10.2'
  # spec.dependency 'Moya', '~> 15.0.0'
  # spec.dependency 'SwiftyJSON', '~> 5.0.2'
  # spec.dependency 'ApolloOTA'

  # # 模块名称
  # spec.module_name = 'RingsSDK'
  
  # # 公开头文件
  # spec.public_header_files = 'RingsSDK/**/*.h'
  
  # # 添加头文件搜索路径
  # spec.pod_target_xcconfig = {
  #   'DEFINES_MODULE' => 'YES',
  #   'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  #   'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/RingsSDK/Classes/OTATool'
  # }

  # # 添加头文件搜索路径
  # spec.xcconfig = { 
  #   'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/RingsSDK/RingsSDK/Classes/OTATool',
  #   'SWIFT_INCLUDE_PATHS' => '${PODS_ROOT}/RingsSDK/RingsSDK'
  # }
end