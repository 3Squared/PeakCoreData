Pod::Spec.new do |s|

  s.name         = "PeakCoreData"
  s.version      = "3.2.0"
  s.summary      = "PeakCoreData is a Swift microframework providing enhancements and conveniences to Core Data. It is part of the Peak Framework."
  s.homepage     = "https://github.com/3squared/PeakCoreData"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "David Yates" => "david.yates@3squared.com" }
  s.platform     = :ios, "10.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/3squared/PeakCoreData.git", :tag => s.version.to_s }
  s.source_files = "PeakCoreData", "PeakCoreData/**/*.{h,m,swift}"
  s.dependency 'PeakOperation'
  s.swift_version = '5.0'

end
