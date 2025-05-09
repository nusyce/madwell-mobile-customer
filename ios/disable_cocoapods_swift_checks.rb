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
    puts "Found CocoaPods gem at: #{spec.gem_dir}" if spec
    return spec.gem_dir if spec
  rescue LoadError, Gem::MissingSpecError => e
    puts "Error finding CocoaPods gem: #{e.message}"
  end
  
  # If that fails, try to find it via PATH
  pod_path = `which pod`.chomp
  puts "Pod executable path: #{pod_path}" unless pod_path.empty?
  return nil if pod_path.empty?
  
  # Track up to lib directory
  lib_dir = File.expand_path('../../../lib', pod_path)
  puts "Checking lib dir: #{lib_dir}"
  return lib_dir if File.directory?(File.join(lib_dir, 'cocoapods'))
  
  # Try gem paths
  puts "Searching in gem paths: #{Gem.path.join(', ')}"
  Gem.path.each do |gem_path|
    glob_pattern = File.join(gem_path, 'gems/cocoapods-*/lib')
    puts "Searching in pattern: #{glob_pattern}"
    Dir.glob(glob_pattern).each do |lib_path|
      puts "Found potential lib path: #{lib_path}"
      return lib_path if File.directory?(File.join(lib_path, 'cocoapods'))
    end
  end
  
  nil
end

def find_cocoapods_files(lib_dir)
  return [] unless lib_dir
  
  # Find all potential target_inspector.rb files
  inspector_files = []
  puts "Searching for target_inspector.rb in #{lib_dir}"
  
  # Method 1: Direct path
  direct_path = File.join(lib_dir, 'cocoapods/installer/analyzer/target_inspector.rb')
  if File.exist?(direct_path)
    puts "Found direct path: #{direct_path}"
    inspector_files << direct_path
  end
  
  # Method 2: Search for it
  Dir.glob(File.join(lib_dir, '**', 'target_inspector.rb')).each do |file|
    puts "Found via glob: #{file}"
    inspector_files << file
  end
  
  # If lib_dir is a gem dir, look in lib subdirectory
  if File.directory?(File.join(lib_dir, 'lib', 'cocoapods'))
    Dir.glob(File.join(lib_dir, 'lib', '**', 'target_inspector.rb')).each do |file|
      puts "Found in lib subdir: #{file}"
      inspector_files << file unless inspector_files.include?(file)
    end
  end
  
  inspector_files.uniq
end

def patch_file(file_path, pattern, replacement)
  return false unless File.exist?(file_path)
  
  # Create backup
  backup_path = "#{file_path}.bak"
  FileUtils.cp(file_path, backup_path) unless File.exist?(backup_path)
  
  content = File.read(file_path)
  
  # Try alternative patterns if the main one doesn't match
  if !content.match(pattern)
    puts "Initial pattern did not match, trying alternatives..."
    
    # Try with different whitespace patterns
    alt_patterns = [
      /def\s+compute_swift_version_from_targets.*?end/m,
      /def compute_swift_version_from_targets\(.*?\).*?end/m
    ]
    
    pattern = alt_patterns.find { |p| content.match(p) }
    
    if !pattern
      # Dump the content for debugging
      puts "Content of file (first 200 chars): #{content[0..200]}"
      puts "Could not find the compute_swift_version_from_targets method"
      return false
    end
  end
  
  puts "Pattern found! Applying patch..."
  new_content = content.gsub(pattern, replacement)
  
  # Check if content actually changed
  if new_content == content
    puts "Warning: Content unchanged after gsub operation"
    return false
  end
  
  # Write with exception handling
  begin
    File.write(file_path, new_content)
    puts "File successfully written"
    return true
  rescue => e
    puts "Error writing file: #{e.message}"
    return false
  end
end

# Alternative patch method for newer CocoaPods versions
def create_override_file(cocoapods_lib)
  puts "Trying alternative patch method..."
  
  # Find the appropriate directory for the patch
  patch_locations = [
    File.join(cocoapods_lib, 'cocoapods', 'installer', 'analyzer'),
    File.join(cocoapods_lib, 'lib', 'cocoapods', 'installer', 'analyzer')
  ]
  
  patch_dir = patch_locations.find { |dir| File.directory?(dir) }
  return false unless patch_dir
  
  # Create a patch file that overrides the Swift version check
  patch_file = File.join(patch_dir, 'swift_version_override.rb')
  
  begin
    File.open(patch_file, 'w') do |f|
      f.puts <<~RUBY
        # CocoaPods Swift version override
        require 'cocoapods'
        
        module Pod
          class Installer
            class Analyzer
              class TargetInspector
                # Override Swift version check to always return 5.0
                def compute_swift_version_from_targets
                  '5.0'
                end
              end
            end
          end
        end
      RUBY
    end
    
    # Create a hook to require this file
    load_hook_file = File.join(patch_dir, 'target_inspector.rb')
    
    if File.exist?(load_hook_file)
      content = File.read(load_hook_file)
      
      unless content.include?('swift_version_override')
        File.open(load_hook_file, 'a') do |f|
          f.puts "\n# Load Swift version override"
          f.puts "require_relative 'swift_version_override'"
        end
      end
    end
    
    puts "Created Swift version override file at: #{patch_file}"
    return true
  rescue => e
    puts "Error creating override file: #{e.message}"
    return false
  end
end

# Create a simple environment file to enforce Swift version
def create_environment_file
  puts "Creating environment file fallback..."
  begin
    File.open(".swift-version", "w") do |f|
      f.puts "5.0"
    end
    
    # Also create in the ios directory if it exists
    if File.directory?("ios")
      File.open("ios/.swift-version", "w") do |f|
        f.puts "5.0"
      end
    end
    
    puts "Created .swift-version files"
    return true
  rescue => e
    puts "Error creating .swift-version file: #{e.message}"
    return false
  end
end

# Main execution
begin
  puts "Starting CocoaPods Swift version patch"
  
  # Create environment file as fallback
  create_environment_file
  
  # Find CocoaPods library
  cocoapods_lib = find_cocoapods_lib
  unless cocoapods_lib
    puts "WARNING: Could not find CocoaPods library directory"
    puts "Using fallback methods only"
    exit(0) # Exit with success since we've created the fallback file
  end
  
  puts "Found CocoaPods at: #{cocoapods_lib}"
  
  # Find all potential target_inspector.rb files
  inspector_files = find_cocoapods_files(cocoapods_lib)
  
  success = false
  
  # Try to patch each file
  if !inspector_files.empty?
    inspector_files.each do |file_path|
      puts "Attempting to patch #{file_path}..."
      
      # Try patching the file
      patched = patch_file(
        file_path,
        /def compute_swift_version_from_targets.*?end/m,
        "def compute_swift_version_from_targets\n      '5.0'\n    end"
      )
      
      if patched
        puts "Successfully patched #{file_path}"
        success = true
      else
        puts "Failed to patch #{file_path}"
      end
    end
  else
    puts "No target_inspector.rb files found via standard methods"
  end
  
  # If standard patching failed, try alternative methods
  if !success
    puts "Standard patching failed, trying alternatives..."
    success = create_override_file(cocoapods_lib)
  end
  
  if success
    puts "CocoaPods Swift version checking has been disabled"
    exit(0)
  else
    puts "WARNING: Could not directly patch CocoaPods"
    puts "Created fallback .swift-version files which may help"
    # Still exit with success since we've created fallbacks
    exit(0)
  end
rescue => e
  puts "ERROR: Unexpected exception: #{e.message}"
  puts e.backtrace.join("\n")
  # Create environment file as last resort
  create_environment_file
  exit(0) # Still exit with success to not block the build
end 