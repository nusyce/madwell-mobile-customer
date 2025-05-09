#!/usr/bin/env ruby
require 'xcodeproj'

begin
  puts "Opening project..."
  project_path = 'Runner.xcodeproj'
  project = Xcodeproj::Project.open(project_path)

  puts "Finding main target..."
  target = project.targets.find { |t| t.name == 'Runner' }
  unless target
    puts "Error: Target 'Runner' not found!"
    exit 1
  end

  puts "Creating Staging configuration based on Release..."
  # Create a Staging configuration based on Release
  # Project-level configuration
  release_config = project.build_configuration_list.build_configurations.find { |config| config.name == 'Release' }
  unless release_config
    puts "Error: Release configuration not found!"
    exit 1
  end

  # Check if Staging config already exists
  staging_config = project.build_configuration_list.build_configurations.find { |config| config.name == 'Staging' }
  if staging_config
    puts "Staging configuration already exists at project level, updating it..."
    staging_config.build_settings = release_config.build_settings.dup
    staging_config.base_configuration_reference = project.new_file('Flutter/Staging.xcconfig')
  else
    puts "Creating new Staging configuration at project level..."
    staging_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
    staging_config.name = 'Staging'
    staging_config.build_settings = release_config.build_settings.dup
    staging_config.base_configuration_reference = project.new_file('Flutter/Staging.xcconfig')
    project.build_configuration_list.build_configurations << staging_config
  end

  # Target-level configuration
  puts "Creating Staging configuration for target..."
  release_target_config = target.build_configuration_list.build_configurations.find { |config| config.name == 'Release' }
  unless release_target_config
    puts "Error: Release configuration not found for target!"
    exit 1
  end

  # Check if Staging config already exists for target
  staging_target_config = target.build_configuration_list.build_configurations.find { |config| config.name == 'Staging' }
  if staging_target_config
    puts "Staging configuration already exists for target, updating it..."
    staging_target_config.build_settings = release_target_config.build_settings.dup
    staging_target_config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'app.madwell.pro.customer.staging'
    staging_target_config.base_configuration_reference = project.new_file('Flutter/Staging.xcconfig')
  else
    puts "Creating new Staging configuration for target..."
    staging_target_config = target.project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
    staging_target_config.name = 'Staging'
    staging_target_config.build_settings = release_target_config.build_settings.dup
    staging_target_config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'app.madwell.pro.customer.staging'
    staging_target_config.base_configuration_reference = project.new_file('Flutter/Staging.xcconfig')
    target.build_configuration_list.build_configurations << staging_target_config
  end

  # Save the project
  puts "Saving project..."
  project.save
  puts "Done!"
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
  exit 1
end 