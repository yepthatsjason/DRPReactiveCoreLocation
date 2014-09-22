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
  s.version          = "0.1.0"
  s.summary          = "A short description of DRPStarterKit."
  s.description      = <<-DESC
                       An optional longer description of DRPStarterKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/DRPStarterKit"
  s.author           = { "Jason Ederle" => "jason.ederle@gmail.com" }
  s.source           = { :path => "/Users/jederle/dropbox_personal/Projects/Private Pods/DRPStarterKit" }
  s.social_media_url = 'https://facebook.com/jason.ederle'
  
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'DRPStarterKit' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  # s.dependency 'AFNetworking', '~> 2.3'
end
