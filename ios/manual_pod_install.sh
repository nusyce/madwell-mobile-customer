#!/bin/bash

# This script manually handles pod installation with Swift version bypass

echo "Performing manual pod installation..."

# Clean state
rm -rf Pods
rm -f Podfile.lock

# Fix Swift version in Xcode project
ruby fix_swift_version.rb

# First try to patch CocoaPods (simpler method)
# Create temporary patch file
cat > patch_cocoapods.rb << 'EOF'
#!/usr/bin/env ruby
begin
  require 'fileutils'
  require 'rubygems'
  require 'pathname'

  # Find CocoaPods installation path
  gem_paths = Gem.path + [Gem.default_dir]
  
  target_inspector_paths = []
  gem_paths.each do |gem_path|
    path = Dir.glob(File.join(gem_path, "gems/cocoapods-*/lib/cocoapods/installer/analyzer/target_inspector.rb"))
    target_inspector_paths.concat(path)
  end
  
  if target_inspector_paths.empty?
    puts "Could not find CocoaPods target_inspector.rb"
    exit(1)
  end
  
  target_inspector_path = target_inspector_paths.first
  puts "Found target_inspector.rb at: #{target_inspector_path}"
  
  # Create backup if it doesn't exist
  backup_path = "#{target_inspector_path}.bak"
  FileUtils.cp(target_inspector_path, backup_path) unless File.exist?(backup_path)
  
  # Read the file
  content = File.read(target_inspector_path)
  
  # Replace the problematic method with a fixed version
  patched_content = content.gsub(
    /def compute_swift_version_from_targets.*?end/m, 
    "def compute_swift_version_from_targets\n      '5.0'\n    end"
  )
  
  # Write the patched content
  File.write(target_inspector_path, patched_content)
  
  puts "Successfully patched CocoaPods to always use Swift 5.0"
rescue => e
  puts "Error patching CocoaPods: #{e.message}"
  puts e.backtrace.join("\n")
  exit(1)
end
EOF

# Make patch script executable
chmod +x patch_cocoapods.rb

# Run the patch script
ruby patch_cocoapods.rb

# Now run pod install
echo "Running pod install with patched CocoaPods..."
COCOAPODS_DISABLE_STATS=true pod install --verbose

# Apply our fixes again after pod install
ruby fix_cocoapods.rb
ruby fix_swift_version.rb

echo "Manual pod installation completed" 