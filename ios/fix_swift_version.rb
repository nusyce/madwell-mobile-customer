#!/usr/bin/env ruby
# Make sure xcodeproj gem is installed
begin
  require 'xcodeproj'
rescue LoadError
  system('gem install xcodeproj')
  require 'xcodeproj'
end

# Open the Xcode project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Runner' }
return unless target

puts "Found target: #{target.name}"

# Set consistent Swift version for all build configurations
swift_version = '5.0'
puts "Setting Swift version to #{swift_version} for all configurations"

# Clear any Swift version settings from the project's build configurations
project.build_configurations.each do |config|
  config.build_settings.delete('SWIFT_VERSION')
end

# Set consistent Swift version on target level
target.build_configurations.each do |config|
  # Remove any existing SWIFT_VERSION settings to avoid duplicates
  config.build_settings.delete('SWIFT_VERSION')
  
  # Set the Swift version
  config.build_settings['SWIFT_VERSION'] = swift_version
  
  puts "Updated #{config.name} configuration"
end

# Clear compiler flags that might conflict with Swift version
target.build_phases.each do |phase|
  if phase.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
    phase.files.each do |file|
      if file.settings && file.settings['COMPILER_FLAGS']
        # Remove any Swift version related flags from compiler flags
        file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS'].gsub(/-swift-version\s+\d+(\.\d+)?/, '')
      end
    end
  end
end

# Save the project
puts "Saving project"
project.save

# Also fix the pbxproj file directly for any instances we might have missed
pbxproj_path = "#{project_path}/project.pbxproj"
if File.exist?(pbxproj_path)
  puts "Direct fixing project.pbxproj file"
  content = File.read(pbxproj_path)
  # Replace any Swift version that isn't 5.0
  content.gsub!(/SWIFT_VERSION\s*=\s*[^5].*?;/, "SWIFT_VERSION = #{swift_version};")
  # Replace empty Swift version
  content.gsub!(/SWIFT_VERSION\s*=\s*;/, "SWIFT_VERSION = #{swift_version};")
  File.write(pbxproj_path, content)
end

puts "Swift version updated successfully!" 