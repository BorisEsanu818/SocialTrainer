# source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
#  platform :ios, ’10.2’

target 'TrainersSociety' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TrainersSociety

  # UI
  pod 'Lightbox'
  pod 'iCarousel'
  pod 'Material', '~> 2.4'
  pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'feature/Xcode9-Swift3_2'
  
  pod 'ImageRow'
  pod 'Cosmos', '~> 8.0'
  pod 'Presentr'

  # Booking
  pod 'FSCalendar'
  
  # Push Send Notifications
  pod 'OneSignal', '>= 2.5.2', '< 3.0'

  # Mailgun
  pod 'SwiftMailgun'
  
  # SignIn
  pod 'GoogleSignIn'
  pod 'Bolts'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'

  # Messaging
  pod 'JSQMessagesViewController'
  pod 'SDWebImage'

  # Firebase
  pod 'Firebase/Storage'
  pod 'Firebase/Auth'
  pod 'Firebase/Crash'
  pod 'Firebase/Database'
  pod 'Firebase/RemoteConfig'
  
  #Youtube Video
  pod 'youtube-ios-player-helper', '~> 0.1.4'
  
  pod 'MBProgressHUD'


  #Testing
  pod 'Fabric'
  pod 'Crashlytics'

  target 'TrainersSocietyTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Firebase'
    pod 'Firebase/Storage'
  end

  target 'TrainersSocietyUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'OneSignalNotificationServiceExtension' do
    inherit! :search_paths
    # Push Send Notifications
    pod 'OneSignal', '>= 2.5.2', '< 3.0'
  end

end
