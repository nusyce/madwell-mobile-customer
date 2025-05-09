#!/usr/bin/env ruby
# This script directly patches CocoaPods to avoid Swift version conflicts

# Path to the target_inspector.rb file in the CocoaPods gem
require 'rubygems'
require 'cocoapods'

# Get the path to the cocoapods gem installation
gem_path = Gem.loaded_specs['cocoapods'].full_gem_path
target_inspector_file = File.join(gem_path, 'lib', 'cocoapods', 'installer', 'analyzer', 'target_inspector.rb')

if File.exist?(target_inspector_file)
  puts "Found target_inspector.rb at: #{target_inspector_file}"
  
  content = File.read(target_inspector_file)
  
  # Back up the original file
  backup_file = "#{target_inspector_file}.bak"
  File.write(backup_file, content) unless File.exist?(backup_file)
  
  # Patch the compute_swift_version_from_targets method to always return '5.0'
  if content.include?('def compute_swift_version_from_targets')
    puts "Patching compute_swift_version_from_targets method"
    
    # Replace the method with a simplified version that always returns 5.0
    patched_content = content.gsub(
      /def compute_swift_version_from_targets.*?end/m,
      "def compute_swift_version_from_targets\n      '5.0'\n    end"
    )
    
    # Write the patched content back to the file
    File.write(target_inspector_file, patched_content)
    puts "CocoaPods patched successfully to always use Swift 5.0"
  else
    puts "Could not find the compute_swift_version_from_targets method in the file"
  end
else
  puts "Could not find the target_inspector.rb file"
end

puts "Patch completed" 