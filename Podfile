# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'pianoLearningApp' do
use_frameworks!

pod 'AudioKit'
pod 'LSFloatingActionMenu', '~> 1.0.0'
pod 'PianoView'
end

post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
end
end
