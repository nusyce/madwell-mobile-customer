#!/bin/bash

# Script to update native configuration files with values from .env files
# Usage: ./update_native_config.sh [env_name]
# Example: ./update_native_config.sh dev

# Function to display a header
function display_header() {
  echo "======================================"
  echo "$1"
  echo "======================================"
}

# Check arguments
if [ $# -eq 0 ]; then
  ENV_NAME="dev"
  echo "No environment specified. Using default: $ENV_NAME"
else
  ENV_NAME=$1
fi

ENV_FILE=".env.$ENV_NAME"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file $ENV_FILE not found!"
  echo "Make sure to run setup_env.sh first to create the environment files."
  exit 1
fi

display_header "Updating native configuration for $ENV_NAME environment"

# Make Android update script executable and run it
if [ -f "android/update_manifest.sh" ]; then
  echo "Updating Android configuration..."
  chmod +x android/update_manifest.sh
  cd android && ./update_manifest.sh $ENV_NAME
  cd ..
  echo "Android configuration updated successfully."
else
  echo "Android update script not found. Skipping Android configuration."
fi

# Make iOS update script executable and run it
if [ -f "ios/update_infoplist.sh" ]; then
  echo "Updating iOS configuration..."
  chmod +x ios/update_infoplist.sh
  cd ios && ./update_infoplist.sh $ENV_NAME
  cd ..
  echo "iOS configuration updated successfully."
else
  echo "iOS update script not found. Skipping iOS configuration."
fi

display_header "Native configuration update complete"
echo "Native configuration has been updated for $ENV_NAME environment." 