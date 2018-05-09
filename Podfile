ENV['COCOAPODS_DISABLE_STATS'] = "true"
inhibit_all_warnings!

def common_pods
end

target 'Kanboard iOS' do
  platform :ios, '11.0'
  use_frameworks!

  common_pods

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
