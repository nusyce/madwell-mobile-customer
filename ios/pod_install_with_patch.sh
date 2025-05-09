#!/bin/bash

# This script handles pod installation with Swift version patches
# It creates necessary files and environment settings to force Swift 5.0

echo "Running pod install with Swift version patch..."

# Create .swift-version file
echo "5.0" > .swift-version

# Create a temporary environment file for use with pod install
cat > .xcode-version << 'EOL'
5.0
EOL

# Clean existing pods
if [ -d "Pods" ]; then
  echo "Cleaning existing Pods directory..."
  rm -rf Pods
fi

if [ -f "Podfile.lock" ]; then
  echo "Removing Podfile.lock..."
  rm -f Podfile.lock
fi

# Try to patch CocoaPods
if [ -f "disable_cocoapods_swift_checks.rb" ]; then
  echo "Attempting to patch CocoaPods..."
  ruby disable_cocoapods_swift_checks.rb || true
fi

# Set environment variables to help with Swift version
export SWIFT_VERSION=5.0

# Force Swift 5.0 for all Pod targets by patching project.pbxproj files after pod install
patch_swift_version() {
  echo "Patching Swift version in Xcode project files..."
  
  # Fix main project
  if [ -f "Runner.xcodeproj/project.pbxproj" ]; then
    echo "Patching Runner.xcodeproj/project.pbxproj"
    sed -i '' 's/SWIFT_VERSION = "";/SWIFT_VERSION = "5.0";/g' Runner.xcodeproj/project.pbxproj
    sed -i '' 's/SWIFT_VERSION = \([^5].*\);/SWIFT_VERSION = "5.0";/g' Runner.xcodeproj/project.pbxproj
  fi
  
  # Fix Pods project
  if [ -f "Pods/Pods.xcodeproj/project.pbxproj" ]; then
    echo "Patching Pods/Pods.xcodeproj/project.pbxproj"
    sed -i '' 's/SWIFT_VERSION = "";/SWIFT_VERSION = "5.0";/g' Pods/Pods.xcodeproj/project.pbxproj
    sed -i '' 's/SWIFT_VERSION = \([^5].*\);/SWIFT_VERSION = "5.0";/g' Pods/Pods.xcodeproj/project.pbxproj
  fi
}

# First attempt: standard pod install
echo "Attempting standard pod install..."
COCOAPODS_DISABLE_STATS=true pod install --verbose || true

# Apply Swift version fix regardless of success
patch_swift_version

# Second attempt with repo update if first failed
if [ ! -d "Pods" ] || [ ! -f "Pods/Manifest.lock" ]; then
  echo "First attempt failed, trying with repo update..."
  COCOAPODS_DISABLE_STATS=true pod install --repo-update --verbose || true
  patch_swift_version
fi

# If we still don't have Pods, try one last time with --no-integrate
if [ ! -d "Pods" ] || [ ! -f "Pods/Manifest.lock" ]; then
  echo "Still failing, trying with --no-integrate..."
  COCOAPODS_DISABLE_STATS=true pod install --no-integrate --verbose || true
  patch_swift_version
fi

# Verify Pod installation
if [ -d "Pods" ] && [ -f "Pods/Manifest.lock" ]; then
  echo "Pod installation succeeded"
else
  echo "WARNING: Pod installation may have failed, but continuing build process"
fi

echo "Pod install with patches completed" 