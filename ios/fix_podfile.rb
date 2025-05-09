#!/usr/bin/env ruby
# This script doesn't require bundler as it only uses standard Ruby libraries

podfile_path = 'Podfile'
file_content = File.read(podfile_path)

# Update the Podfile to include a Staging configuration
unless file_content.include?('project \'Runner\', {')
  puts "Error: Cannot find the project configuration line in Podfile"
  exit 1
end

# Make sure Staging is included in the project configurations
if !file_content.include?("'Staging' => :release")
  file_content.gsub!(
    /project 'Runner', {[^}]*}/,
    "project 'Runner', {\n  'Debug' => :debug,\n  'Profile' => :release,\n  'Release' => :release,\n  'Staging' => :release,\n}"
  )
  puts "Added Staging configuration to project settings"
end

# Ensure we're handling Swift version consistently
swift_version_code = "      # Ensure consistent Swift version\n      config.build_settings['SWIFT_VERSION'] = '5.0'\n"
if !file_content.include?("config.build_settings['SWIFT_VERSION'] = '5.0'")
  file_content.gsub!(
    /config\.build_settings\['IPHONEOS_DEPLOYMENT_TARGET'\] = '.*'/,
    "#{swift_version_code}      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'"
  )
  puts "Added Swift version configuration"
end

# Save the updated Podfile
File.write(podfile_path, file_content)
puts "Podfile updated successfully!" 