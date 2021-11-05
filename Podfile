platform :ios, '12.0'
inhibit_all_warnings!

def is_pod_binary_cache_enabled
  ENV['IS_POD_BINARY_CACHE_ENABLED'] == 'true'
end

if is_pod_binary_cache_enabled
  plugin 'cocoapods-binary-cache'
  config_cocoapods_binary_cache(
    cache_repo: {
      "default" => {
        "remote" => "git@github.com:aaronlab/bottom-sheet-example.git",
        "local" => "~/.cocoapods-binary-cache/bottom-sheet-example-libs"
      }
    },
    prebuild_config: "Debug",
    dev_pods_enabled: true,
    device_build_enabled: true
  )
end

def binary_pod(name, *args)
  if is_pod_binary_cache_enabled
    pod name, args, :binary => true
  else
    pod name, args
  end
end

def available_pods

  # Rx
  binary_pod 'RxSwift', '< 6.2.0'
  binary_pod 'RxCocoa', '< 6.2.0'
  binary_pod 'RxGesture', '< 4.1.0'

  # Others
  binary_pod 'SnapKit', '< 5.1.0'
  binary_pod 'Then', '< 2.8.0'

end

target 'BottomSheetExample' do

  use_frameworks!
  available_pods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end