#!/usr/bin/env ruby

# This script disables Swift version checking in CocoaPods by directly
# modifying the source code without relying on environment variables

require 'fileutils'
require 'pathname'

def find_cocoapods_lib
  # Try to get CocoaPods location from Ruby gems
  begin
    require 'rubygems'
    spec = Gem::Specification.find_by_name('cocoapods')
    return spec.gem_dir if spec
  rescue LoadError, Gem::MissingSpecError => e
    puts "Error finding CocoaPods gem: #{e.message}"
  end
  
  # If that fails, try to find it via PATH
  pod_path = `which pod`.chomp
  return nil if pod_path.empty?
  
  # Track up to lib directory
  lib_dir = File.expand_path('../../../lib', pod_path)
  return lib_dir if File.directory?(File.join(lib_dir, 'cocoapods'))
  
  # Try gem paths
  Gem.path.each do |gem_path|
    Dir.glob(File.join(gem_path, 'gems/cocoapods-*/lib')).each do |lib_path|
      return lib_path if File.directory?(File.join(lib_path, 'cocoapods'))
    end
  end
  
  nil
end

def patch_file(file_path, pattern, replacement)
  return false unless File.exist?(file_path)
  
  # Create backup
  backup_path = "#{file_path}.bak"
  FileUtils.cp(file_path, backup_path) unless File.exist?(backup_path)
  
  content = File.read(file_path)
  if content.include?(pattern)
    new_content = content.gsub(pattern, replacement)
    File.write(file_path, new_content)
    return true
  end
  
  false
end

# Find CocoaPods library
cocoapods_lib = find_cocoapods_lib
unless cocoapods_lib
  puts "Could not find CocoaPods library directory"
  exit(1)
end

puts "Found CocoaPods at: #{cocoapods_lib}"
success = false

# Patch target_inspector.rb
target_inspector_path = File.join(cocoapods_lib, 'cocoapods/installer/analyzer/target_inspector.rb')
if File.exist?(target_inspector_path)
  puts "Patching #{target_inspector_path}..."
  patched = patch_file(
    target_inspector_path,
    /def compute_swift_version_from_targets.*?end/m,
    "def compute_swift_version_from_targets\n      '5.0'\n    end"
  )
  if patched
    puts "Successfully patched compute_swift_version_from_targets method"
    success = true
  else
    puts "Could not patch compute_swift_version_from_targets method"
  end
end

if success
  puts "CocoaPods Swift version checking has been disabled"
else
  puts "Failed to disable CocoaPods Swift version checking"
  exit(1)
end 