ENV['COCOAPODS_DISABLE_STATS'] = "true"
inhibit_all_warnings!

platform :ios, '13.0'
use_frameworks!

target 'Kanboard' do
  # Using Swift Package Manager instead to support Catalysis.
  # See https://github.com/realm/realm-cocoa/issues/6163
  # pod 'RealmSwift', '~> 3.17.3'

  pod 'SnapKit', '~> 5.0.1'
  pod 'Willow', '~> 5.2.1'

  target 'Kanboard Tests' do
    inherit! :search_paths
  end
end
