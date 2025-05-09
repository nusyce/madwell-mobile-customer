#!/bin/bash

# This script installs pods while bypassing the Swift version conflict

echo "Running patched pod install..."

# First, make sure we have a clean state
rm -rf Pods
rm -f Podfile.lock

# Fix Swift version in the main project
ruby fix_swift_version.rb

# Create temp directory for patching CocoaPods
TEMP_DIR=$(mktemp -d)
echo "Created temp directory: $TEMP_DIR"

# Create wrapper script for pod command that modifies the environment
cat > $TEMP_DIR/pod << 'EOF'
#!/bin/bash
# Get the path to the real pod executable
REAL_POD=$(which -a pod | grep -v $TEMP_DIR | head -n 1)

# Set environment variables to bypass Swift version checks
export COCOAPODS_DISABLE_STATS=true
export SKIP_SWIFT_VERSION_CHECK=1

# Run the real pod command with all arguments
COCOAPODS_SKIP_SWIFT_VERSION_CHECK=1 $REAL_POD "$@"
EOF

# Make the wrapper executable
chmod +x $TEMP_DIR/pod

# Add the temp directory to the front of the PATH
export PATH="$TEMP_DIR:$PATH"

# Run pod install with the wrapper
pod install --verbose --no-repo-update

# Clean up
rm -rf $TEMP_DIR

# Apply Swift version fixes after installation
ruby fix_cocoapods.rb
ruby fix_swift_version.rb

echo "Pod installation completed" 