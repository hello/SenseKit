
Pod::Spec.new do |s|
  s.name             = "SenseKit"
  s.version          = "0.1.0"
  s.summary          = "Toolkit for building Sense apps"
  s.homepage         = "https://github.com/hello/SenseKit"
  s.author           = { "Delisa Mason" => "iskanamagus@gmail.com", "Jimmy Lu" => "jimmy.m.lu@gmail.com" }
  s.source           = { :git => "https://github.com/hello/SenseKit.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.subspec "Analytics" do |ss|
    ss.source_files = 'Pod/Classes/Analytics/*'
    ss.dependency 'CocoaLumberjack', '~> 2.0.0'
  end

  s.subspec "API" do |ss|
    ss.source_files = 'Pod/Classes/API/*'
    ss.dependency 'FXKeychain', '~> 1.5.1'
    ss.dependency 'AFNetworking', '~> 3.1.0'
    ss.dependency 'NSJSONSerialization-NSNullRemoval', '~> 1.0.0'
  end

  s.subspec "BLE" do |ss|
    ss.source_files = 'Pod/Classes/BLE/**/*.{h,m}'
    ss.dependency 'LGBluetooth'
    ss.dependency 'SHSProtoBuf'
    ss.dependency 'iOSDFULibrary', '2.1.6'
    ss.dependency 'CocoaLumberjack', '~> 2.0.0'
  end

  s.subspec "Model" do |ss|
    ss.source_files = 'Pod/Classes/Model/**/*.{h,m}'
    ss.dependency 'CGFloatType', '~> 1.3.1'
  end

  s.subspec "Service" do |ss|
    ss.source_files = 'Pod/Classes/Service/*'
    ss.dependency 'CocoaLumberjack', '~> 2.0.0'
  end

  s.source_files = 'Pod/Classes/SenseKit.h'
end
