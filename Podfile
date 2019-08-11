ENV['COCOAPODS_DISABLE_STATS'] = "true"
inhibit_all_warnings!

platform :ios, '11.0'
use_frameworks!

target 'Kanboard' do
  pod 'RealmSwift', '~> 3.17.3'
  pod 'SnapKit', '~> 5.0.1'
  pod 'Willow', '~> 5.2.1'
  pod 'JGProgressHUD', '~> 2.0.4'

  target 'Kanboard Tests' do
    inherit! :search_paths
  end
end
