ENV['COCOAPODS_DISABLE_STATS'] = "true"
inhibit_all_warnings!

target 'Kanboard iOS' do
  platform :ios, '11.0'
  use_frameworks!

  pod 'RealmSwift', '~> 3.17.3'
  pod 'SnapKit', '~> 5.0.1'
  pod 'Willow', '~> 5.2.1'
  pod 'JGProgressHUD', '~> 2.0.4'

  target 'Kanboard iOSTests' do
    inherit! :search_paths
  end
end
