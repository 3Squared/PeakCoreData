#
#  Be sure to run `pod spec lint SQKCoreDataKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "THRCoreData"
  s.version      = "0.2.4"
  s.summary      = "Lightweight Core Data helper to reduce boilerplate code."
  s.homepage     = "https://gitlab.3squared.com/iOSLibraries/THRCoreData.git"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "David Yates" => "david.yates@3squared.com" }
  s.platform     = :ios, "9.0"
  s.requires_arc = true
  s.source       = { :git => "git@gitlab.3squared.com:iOSLibraries/THRCoreData.git", :tag => s.version.to_s }
  s.source_files = "THRCoreData", "THRCoreData/**/*.{h,m,swift}"
  s.dependency 'THROperations'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

end
