ENV['COCOAPODS_DISABLE_STATS'] = "true"
inhibit_all_warnings!

def common_pods
    pod 'RealmSwift', '~> 3.5.0'
    pod 'SnapKit', '~> 4.0.0'
    pod 'Willow', '~> 5.0.2'
end

target 'Kanboard iOS' do
  platform :ios, '11.0'
  use_frameworks!

  common_pods
  pod 'JGProgressHUD', '~> 2.0.3'

  target 'Kanboard iOSTests' do
    inherit! :search_paths
  end
end

target 'Kanboard macOS' do
  platform :osx, '10.13'
  use_frameworks!

  common_pods

  target 'Kanboard macOSTests' do
    inherit! :search_paths
  end
end
