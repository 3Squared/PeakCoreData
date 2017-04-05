#
#  Be sure to run `pod spec lint THRCoreData.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "THRCoreData"
  s.version      = "0.4.1"
  s.summary      = "Lightweight Core Data helper to reduce boilerplate code."
  s.homepage     = "https://gitlab.3squared.com/iOSLibraries/THRCoreData"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "David Yates" => "david.yates@3squared.com" }
  s.platform     = :ios, "9.0"
  s.requires_arc = true
  s.source       = { :git => "git@gitlab.3squared.com:iOSLibraries/THRCoreData.git", :tag => s.version.to_s }
  s.default_subspec = 'Core'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

  s.subspec 'Core' do |cs|
    cs.source_files = "THRCoreData/Core/*.{h,m,swift}"
    cs.dependency 'THROperations'
  end
  
  s.subspec 'Network' do |ns|
    ns.source_files = "THRCoreData/Network/*.{h,m,swift}"
    ns.dependency 'THRCoreData/Core'
    ns.dependency 'THRNetwork'
    ns.dependency 'THROperations'
  end

end
