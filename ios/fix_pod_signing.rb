#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Pods project
pods_project_path = 'Pods/Pods.xcodeproj'
return unless File.exist?(pods_project_path)

puts "Opening Pods project"
pods_project = Xcodeproj::Project.open(pods_project_path)

# Iterate through all targets in the Pods project
pods_project.targets.each do |target|
  puts "Processing target: #{target.name}"
  
  # Get all build configurations
  target.build_configurations.each do |config|
    # Set automatic signing for all targets
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings.delete('PROVISIONING_PROFILE_SPECIFIER')
    config.build_settings.delete('PROVISIONING_PROFILE')
    
    # Ensure DEVELOPMENT_TEAM is not set for pods
    config.build_settings.delete('DEVELOPMENT_TEAM')
    
    # Add Staging configuration if needed
    if config.name == 'Release' && !target.build_configurations.any? { |c| c.name == 'Staging' }
      staging_config = target.project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      staging_config.name = 'Staging'
      staging_config.build_settings = config.build_settings.dup
      target.build_configurations << staging_config
    end
  end
end

# Save the project
puts "Saving Pods project"
pods_project.save

puts "Pods project updated successfully!" 