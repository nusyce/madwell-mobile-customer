#!/usr/bin/env ruby

# Script to modify rive_types.hpp to recognize Staging configuration as Release build
require 'fileutils'

# Find the rive_types.hpp file - it should be in a symlink in the .symlinks directory
def find_rive_types
  rive_types_pattern = ".symlinks/plugins/rive_common/ios/rive-cpp/include/rive/rive_types.hpp"
  full_path = File.expand_path(rive_types_pattern)
  
  if File.exist?(full_path)
    return full_path
  else
    puts "Searching for rive_types.hpp in plugin folders..."
    # Try to find it in a different location
    plugins_dir = ".symlinks/plugins"
    Dir.glob("#{plugins_dir}/**/rive_types.hpp").each do |file|
      puts "Found #{file}"
      return file
    end
  end
  
  nil
end

rive_types_path = find_rive_types

if rive_types_path && File.exist?(rive_types_path)
  puts "Found rive_types.hpp at #{rive_types_path}"
  
  # Read the file
  original = File.read(rive_types_path)
  
  # Create a backup
  FileUtils.cp(rive_types_path, "#{rive_types_path}.bak")
  
  # Modify the file to recognize Staging as Release configuration
  modified = original.gsub(
    /#if defined\(DEBUG\) \|\| defined\(_DEBUG\)/, 
    %{#if (defined(DEBUG) || defined(_DEBUG)) && !defined(NDEBUG) && !defined(FLUTTER_RELEASE)}
  )
  
  # Write the modified file
  File.write(rive_types_path, modified)
  
  puts "Updated #{rive_types_path}"
else
  puts "Could not find rive_types.hpp"
end 