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

target.build_configurations.each do |config|
  # Remove any existing SWIFT_VERSION settings to avoid duplicates
  config.build_settings.delete('SWIFT_VERSION')
  
  # Set the Swift version
  config.build_settings['SWIFT_VERSION'] = swift_version
  
  puts "Updated #{config.name} configuration"
end

# Save the project
puts "Saving project"
project.save

puts "Swift version updated successfully!" 