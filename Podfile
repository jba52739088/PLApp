# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
target 'pianoLearningApp' do
use_frameworks!


pod 'AudioKit/Core', '~> 4.4.0', :inhibit_warnings => true
pod 'LSFloatingActionMenu', '~> 1.0.0', :inhibit_warnings => true
pod 'PianoView', '~> 0.0.3', :inhibit_warnings => true
pod 'IQKeyboardManagerSwift', '~> 6.0.4', :inhibit_warnings => true
pod 'Alamofire', '~> 4.5', :inhibit_warnings => true
pod 'AVAudioSessionSetCategorySwift', :inhibit_warnings => true
pod 'SwiftyJSON', '~> 4.0', :inhibit_warnings => true
pod 'SQLite.swift', '0.11.4', :inhibit_warnings => true
pod "SHSearchBar"
end

post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
end
end
