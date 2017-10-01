# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'Lily' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

   # Pods for Lily
    pod 'p2.OAuth2', '~> 3.0'
    pod 'Alamofire', '~> 4.0'
    pod 'Charts'
    pod 'SwiftyJSON'
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'UICircularProgressRing'
    pod "TouchVisualizer", '~>2.0.1'
    pod 'PKHUD', '~> 4.0'
    pod "SwiftSiriWaveformView"
    pod 'SCLAlertView'
    pod 'SendGrid', :git => 'https://github.com/scottkawai/sendgrid-swift.git'
    pod 'IQKeyboardManagerSwift'
    pod 'SMIconLabel'
    pod "BusyNavigationBar"
    pod 'DZNEmptyDataSet'
    pod 'DynamicBlurView'
    target ‘LilyTests’ do
        pod 'p2.OAuth2', '~> 3.0'
        pod 'Alamofire', '~> 4.0'
        pod 'SwiftyJSON'
    end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "3.0"
    end
  end
end
