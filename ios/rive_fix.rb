#!/usr/bin/env ruby

# This script fixes Rive plugin issues by setting proper preprocessor definitions

require 'fileutils'

# Find Rive plugin header files
rive_headers = Dir.glob("./**/*rive_types.hpp")

if rive_headers.empty?
  puts "No Rive header files found"
else
  puts "Found #{rive_headers.length} Rive header files to fix"
  
  rive_headers.each do |file_path|
    puts "Processing #{file_path}..."
    
    # Create backup
    backup_path = "#{file_path}.bak"
    FileUtils.cp(file_path, backup_path) unless File.exist?(backup_path)
    
    # Read the file
    content = File.read(file_path)
    
    # Fix the problematic #error directive by replacing it with NDEBUG definition
    if content.include?("#error \"can't determine if we're debug or release\"")
      puts "  Fixing #error directive..."
      patched_content = content.gsub(
        /#error "can't determine if we're debug or release"/,
        "#define NDEBUG 1"
      )
      
      # Write the patched content
      File.write(file_path, patched_content)
      puts "  Fixed successfully"
    else
      puts "  No issues found in this file"
    end
  end
end

puts "Rive plugin fix completed" 