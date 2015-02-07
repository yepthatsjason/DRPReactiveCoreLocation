#
# Be sure to run `pod lib lint DRPReactiveLocation.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DRPReactiveCoreLocation"
  s.version          = "1.0.3"
  s.summary          = "ReactiveCocoa CoreLocation interface"
  s.description      = <<-DESC
                       ReactiveCocoa interface to CoreLocation. This gives you a signal
                       to handle location and permission change events with.
                       DESC
  s.author           = { "Jason Ederle" => "jason@funly.io" }
  s.license          = 'MIT'
  s.homepage         = "https://github.com/yepthatsjason/DRPReactiveCoreLocation"
  s.source           = { :git => "https://github.com/yepthatsjason/DRPReactiveCoreLocation.git", :tag => s.version.to_s }
  
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*'
  s.resource_bundles = {
    'DRPReactiveLocation' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'ReactiveCocoa'
  
end
