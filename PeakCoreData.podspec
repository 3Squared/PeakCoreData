Pod::Spec.new do |s|

  s.name         = "PeakCoreData"
  s.version      = "2.2.1"
  s.summary      = "Lightweight Core Data helper to reduce boilerplate code."
  s.homepage     = "https://gitlab.3squared.com/MobileTeam/PeakCoreData"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "David Yates" => "david.yates@3squared.com" }
  s.platform     = :ios, "10.0"
  s.requires_arc = true
  s.source       = { :git => "git@gitlab.3squared.com:MobileTeam/PeakCoreData.git", :tag => s.version.to_s }
  s.source_files = "PeakCoreData/*.{h,m,swift}"
  s.dependency 'PeakOperation'
  s.swift_version = '4.2'

end
