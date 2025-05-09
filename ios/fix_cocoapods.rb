#!/usr/bin/env ruby
# Make sure xcodeproj gem is installed
begin
  require 'xcodeproj'
rescue LoadError
  system('gem install xcodeproj')
  require 'xcodeproj'
end

# Open the Pods project if it exists
pods_project_path = 'Pods/Pods.xcodeproj'
unless File.exist?(pods_project_path)
  puts "Pods project not found. Please run 'pod install' first."
  exit
end

puts "Opening Pods project..."
pods_project = Xcodeproj::Project.open(pods_project_path)

# Set a consistent Swift version for all targets
swift_version = '5.0'
puts "Setting Swift version #{swift_version} for all Pod targets..."

# Process all targets
pods_project.targets.each do |target|
  puts "Processing target: #{target.name}"
  
  target.build_configurations.each do |config|
    # Ensure consistent Swift version
    config.build_settings['SWIFT_VERSION'] = swift_version
    
    # Clear any compiler flags that might be setting Swift version
    if config.build_settings['OTHER_SWIFT_FLAGS']
      config.build_settings['OTHER_SWIFT_FLAGS'] = config.build_settings['OTHER_SWIFT_FLAGS'].gsub(/-swift-version\s+\d+(\.\d+)?/, '')
    end
    
    # Ensure automatic code signing
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings.delete('PROVISIONING_PROFILE_SPECIFIER')
    config.build_settings.delete('PROVISIONING_PROFILE')
    config.build_settings.delete('DEVELOPMENT_TEAM')
    
    puts "  Updated #{config.name} configuration"
  end
end

# Save the project
puts "Saving Pods project..."
pods_project.save

# Also fix the pbxproj file directly for any instances we might have missed
pbxproj_path = "#{pods_project_path}/project.pbxproj"
if File.exist?(pbxproj_path)
  puts "Direct fixing Pods/project.pbxproj file"
  content = File.read(pbxproj_path)
  # Replace any Swift version that isn't 5.0
  content.gsub!(/SWIFT_VERSION\s*=\s*[^5].*?;/, "SWIFT_VERSION = #{swift_version};")
  # Replace empty Swift version
  content.gsub!(/SWIFT_VERSION\s*=\s*;/, "SWIFT_VERSION = #{swift_version};")
  File.write(pbxproj_path, content)
end

puts "CocoaPods Swift version fix completed successfully!" 