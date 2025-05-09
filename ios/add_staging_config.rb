#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Runner' }
return unless target

puts "Found target: #{target.name}"

# Get configurations
configs = project.build_configurations
staging_config = configs.find { |config| config.name == 'Staging' }

# If Staging configuration doesn't exist, create it from Release
unless staging_config
  puts "Creating Staging configuration"
  staging_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
  staging_config.name = 'Staging'
  
  # Copy settings from Release
  release_config = configs.find { |config| config.name == 'Release' }
  staging_config.build_settings = release_config.build_settings.dup if release_config
  
  # Add the configuration to the project
  project.build_configurations << staging_config
end

# Update Staging configuration
staging_config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'app.madwell.pro.customer.staging'
staging_config.build_settings['PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]'] = ENV['PROFILE_NAME'] || 'Madwell staging'
staging_config.build_settings['DEVELOPMENT_TEAM'] = ENV['PROFILE_TEAM']
staging_config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
staging_config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
staging_config.build_settings['FLUTTER_TARGET'] = 'lib/main_staging.dart'
staging_config.build_settings['FLUTTER_FLAVOR'] = 'staging'
staging_config.build_settings['FLUTTER_BUILD_MODE'] = 'Release'
staging_config.build_settings['APP_DISPLAY_NAME'] = 'Madwell Pro Staging'
staging_config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['$(inherited)', 'FLUTTER_RELEASE=1', 'NDEBUG=1']

puts "Updating target configurations"

# For each target configuration
target.build_configurations.each do |config|
  if config.name == 'Staging'
    puts "Configuring target Staging configuration"
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'app.madwell.pro.customer.staging'
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]'] = ENV['PROFILE_NAME'] || 'Madwell staging'
    config.build_settings['DEVELOPMENT_TEAM'] = ENV['PROFILE_TEAM']
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
    config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
    config.build_settings['FLUTTER_TARGET'] = 'lib/main_staging.dart'
    config.build_settings['FLUTTER_FLAVOR'] = 'staging'
    config.build_settings['FLUTTER_BUILD_MODE'] = 'Release'
    config.build_settings['APP_DISPLAY_NAME'] = 'Madwell Pro Staging'
    config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'Madwell Pro Staging'
    
    # Ensure proper inclusion of xcconfig
    config.base_configuration_reference = project.new_file('Flutter/Staging.xcconfig')
  end
end

# Create custom schemes for flavors
shared_data_dir = Xcodeproj::XCScheme.shared_data_dir(project_path)
FileUtils.mkdir_p(shared_data_dir)

# First, check if Runner scheme exists
runner_scheme_path = "#{shared_data_dir}/Runner.xcscheme" 
if File.exist?(runner_scheme_path)
  puts "Found Runner scheme, copying for Runner-staging"
  
  # Load the existing Runner scheme
  runner_scheme = Xcodeproj::XCScheme.new(runner_scheme_path)
  
  # Create a new scheme for Runner-staging
  staging_scheme_path = "#{shared_data_dir}/Runner-staging.xcscheme"
  
  # Copy the Runner scheme
  FileUtils.cp(runner_scheme_path, staging_scheme_path)
  
  # Load and modify the staging scheme
  staging_scheme = Xcodeproj::XCScheme.new(staging_scheme_path)
  
  # Update the build action
  staging_scheme.build_action.entries.each do |entry|
    entry.build_for_testing = true
    entry.build_for_running = true
    entry.build_for_profiling = true
    entry.build_for_archiving = true
    entry.build_for_analyzing = true
  end
  
  # Set the staging configuration for each action
  staging_scheme.launch_action.build_configuration = 'Staging'
  staging_scheme.test_action.build_configuration = 'Staging'
  staging_scheme.profile_action.build_configuration = 'Staging'
  staging_scheme.analyze_action.build_configuration = 'Staging'
  staging_scheme.archive_action.build_configuration = 'Staging'
  
  # Save the scheme
  staging_scheme.save!
  puts "Created Runner-staging scheme with Staging configuration"
else
  puts "Warning: Runner.xcscheme not found, cannot create staging scheme!"
end

# Also create a generic scheme specification for Flutter
schemes_file_path = "#{project_path}/xcshareddata/xcschemes/Runner-staging.xcscheme"
FileUtils.mkdir_p(File.dirname(schemes_file_path))

# Make the schemes visible to Xcode
system("touch #{shared_data_dir}/.xcschemelist")

# Save the project
puts "Saving project"
project.save

puts "Xcode project updated successfully!" 