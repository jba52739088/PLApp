# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
target 'pianoLearningApp' do
use_frameworks!


pod 'AudioKit/Core',  :inhibit_warnings => true
# pod 'HHFloatingView', :inhibit_warnings => true
pod 'IQKeyboardManagerSwift', :inhibit_warnings => true
pod 'Alamofire', :inhibit_warnings => true
pod 'AVAudioSessionSetCategorySwift', :inhibit_warnings => true
pod 'SwiftyJSON', :inhibit_warnings => true
pod 'SQLite.swift', :inhibit_warnings => true
end

post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
end
end
