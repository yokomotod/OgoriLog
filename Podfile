source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'OgoriLog' do
  pod 'BlocksKit'
  pod 'Crashlytics'
  pod 'CorePlot'
  pod 'Fabric'
  pod 'SnapKit'
end

target 'OgoriLogTests' do

end

post_install do | installer |
  # workaround for this issue https://github.com/CocoaPods/CocoaPods/issues/4420
  `find Pods -regex 'Pods/Google.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)GoogleMobileAds\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`

  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-OgoriLog/Pods-OgoriLog-acknowledgements.plist', 'OgoriLog/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
