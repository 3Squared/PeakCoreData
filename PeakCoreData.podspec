Pod::Spec.new do |s|

  s.name         = "PeakCoreData"
  s.version      = "4.1.0"
  s.summary      = "PeakCoreData is a Swift microframework providing enhancements and conveniences to Core Data. It is part of the Peak Framework."
  s.homepage     = "https://github.com/3squared/PeakCoreData"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "David Yates" => "david.yates@3squared.com", "Ben Walker" => "ben.walker@3squared.com" }
  s.requires_arc = true
  s.source       = { :git => "https://github.com/3squared/PeakCoreData.git", :tag => s.version.to_s }
  s.source_files = "PeakCoreData", "PeakCoreData/**/*.{h,m,swift}"
  s.dependency 'PeakOperation'
  s.swift_version = '5.0'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.macos.deployment_target = '10.13'

  s.source_files = "PeakCoreData", "PeakCoreData/Core/**/*.{h,m,swift}"
  s.ios.source_files = "PeakCoreData/Platforms/iOS/**/*.{h,m,swift}"
  s.tvos.source_files = "PeakCoreData/Platforms/iOS/**/*.{h,m,swift}"
  s.macos.source_files = "PeakCoreData/Platforms/macOS/**/*.{h,m,swift}"

end
