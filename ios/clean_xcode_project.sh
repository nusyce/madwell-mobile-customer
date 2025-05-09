#!/bin/bash

# This script performs a thorough cleaning of the Xcode project
# to ensure we don't have leftover build artifacts or settings

echo "Performing thorough cleanup of Xcode project..."

# Clean CocoaPods
echo "Removing CocoaPods artifacts..."
rm -rf Pods
rm -f Podfile.lock
rm -rf .symlinks

# Clean Xcode derived data
echo "Removing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*Runner*

# Clean build directories
echo "Removing build directories..."
rm -rf build
mkdir -p build

# Remove any .xcworkspace files except for the main one
find . -name "*.xcworkspace" -not -name "Runner.xcworkspace" -exec rm -rf {} \; 2>/dev/null || true

# Make sure Runner.xcworkspace exists
if [ ! -d "Runner.xcworkspace" ]; then
  echo "Recreating Runner.xcworkspace..."
  mkdir -p Runner.xcworkspace
fi

# Apply Swift version fix
echo "Running Swift version fix..."
ruby fix_swift_version.rb

# Fix Podfile for Staging
echo "Updating Podfile for Staging..."
ruby fix_podfile.rb

echo "Xcode project cleaned successfully!" 