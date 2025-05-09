#!/bin/bash

# This script patches Flutter's build process to handle pod installation correctly

echo "Patching Flutter's build process..."

# Change to project root
cd ..

# First, intercept Flutter's pod installation process
# Create a temporary directory to hold our patched tools
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Create a patched flutter executable that will intercept pod calls
cat > $TEMP_DIR/flutter << 'EOF'
#!/bin/bash

# Get the path to the real flutter
REAL_FLUTTER=$(which -a flutter | grep -v "$(dirname $0)" | head -n 1)

# Check what subcommand is being run
if [[ "$*" == *"build ios"* ]]; then
  echo "Intercepting Flutter iOS build command..."
  
  # Extract the arguments to pass to the real flutter command
  ARGS=("$@")
  
  # Run our manual pod installation first
  echo "Running custom pod install..."
  cd ios
  ./manual_pod_install.sh
  cd ..
  
  # Now run the real Flutter command with specific flags to prevent it from running pod install
  $REAL_FLUTTER "${ARGS[@]}" --no-codesign
else
  # For other commands, just pass through to the real flutter
  $REAL_FLUTTER "$@"
fi
EOF

# Make the wrapper executable
chmod +x $TEMP_DIR/flutter

# Add temp directory to PATH so our patched flutter is found first
export PATH="$TEMP_DIR:$PATH"

# Run the flutter build command through our patched wrapper
flutter build ios --release --dart-define=ENV=staging --config-only

# Clean up
rm -rf $TEMP_DIR

echo "Flutter build completed" 