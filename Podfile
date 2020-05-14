source 'https://github.com/CocoaPods/Specs.git'
target 'YYMusic' do
  platform :ios, '10.0'
  use_frameworks!

  pod 'Alamofire', '~> 5.0.0'
  pod 'Kingfisher', '~> 5.13.1'
  pod 'ObjectMapper', '~> 3.5.1'
  pod 'PKHUD', '~> 5.3.0'
  pod 'SnapKit', '~> 5.0.1'
  pod 'MJRefresh', '~> 3.3.1'
  
  target 'YYMusicTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'YYMusicUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end
