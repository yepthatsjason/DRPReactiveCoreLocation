#
# Be sure to run `pod lib lint DRPStarterKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DRPStarterKit"
  s.version          = "1.0.0"
  s.summary          = "Collection of iOS classes to jumpstart development of new projects"
  s.description      = <<-DESC
                       This pod brings in a common classes that are generic and can be shared among
                       different iOS apps.
                       DESC
  s.author           = { "Jason Ederle" => "jason.ederle@gmail.com" }
  s.homepage         = "http://getatmos.com"
  s.source           = { :path => "/Users/jederle/dropbox_personal/Projects/Private Pods/DRPStarterKit" }
  s.social_media_url = 'https://facebook.com/jason.ederle'
  
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*'
  s.resource_bundles = {
    'DRPStarterKit' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'GoogleAnalytics-iOS-SDK'
  s.dependency 'APAddressBook'
  s.dependency 'ECPhoneNumberFormatter'
  s.dependency 'MBProgressHUD'
  s.dependency 'ReactiveCocoa'
  s.dependency 'GPUImage'
  s.dependency 'APAddressBook'
  s.dependency 'SDWebImage'
  s.dependency 'AFNetworking'
  
end
