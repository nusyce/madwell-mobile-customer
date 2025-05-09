#!/bin/bash

# Script to update Info.plist with values from .env file
# Usage: ./update_infoplist.sh [env_name]
# Example: ./update_infoplist.sh dev

# Default to dev environment if not specified
ENV_NAME=${1:-dev}
ENV_FILE="../.env.$ENV_NAME"
INFO_PLIST="Runner/Info.plist"

echo "===== Updating Info.plist from $ENV_FILE ====="

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file $ENV_FILE not found!"
  echo "Make sure to run setup_env.sh first to create the environment files."
  exit 1
fi

if [ ! -f "$INFO_PLIST" ]; then
  echo "Error: Info.plist file not found at $INFO_PLIST!"
  exit 1
fi

# Function to read a value from .env file
read_env_var() {
  local VAR_NAME=$1
  local DEFAULT_VALUE=$2
  
  if [ -f "$ENV_FILE" ]; then
    local VAR_VALUE=$(grep "^$VAR_NAME=" "$ENV_FILE" | cut -d '=' -f2-)
    if [ -z "$VAR_VALUE" ]; then
      echo "$DEFAULT_VALUE"
    else
      echo "$VAR_VALUE"
    fi
  else
    echo "$DEFAULT_VALUE"
  fi
}

# Read values from .env file
GOOGLE_MAPS_API_KEY=$(read_env_var "GOOGLE_MAPS_API_KEY" "")
ADMOB_APP_ID=$(read_env_var "ADMOB_APP_ID" "ca-app-pub-3940256099942544~1458002511")
APP_NAME=$(read_env_var "APP_NAME" "Madwell")
BUNDLE_ID=$(read_env_var "IOS_BUNDLE_ID" "app.madwell.pro.customer")

echo "Updating Info.plist with the following values:"
echo "- Google Maps API Key: ${GOOGLE_MAPS_API_KEY:0:5}... (truncated for security)"
echo "- AdMob App ID: $ADMOB_APP_ID"
echo "- App Name: $APP_NAME"
echo "- Bundle ID: $BUNDLE_ID"

# Update Info.plist using PlistBuddy
/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$INFO_PLIST" || echo "Failed to update CFBundleName"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" "$INFO_PLIST" || echo "Failed to update CFBundleDisplayName"

# Add GoogleMapsApiKey if it doesn't exist, update it if it does
if /usr/libexec/PlistBuddy -c "Print :GoogleMapsApiKey" "$INFO_PLIST" &>/dev/null; then
  /usr/libexec/PlistBuddy -c "Set :GoogleMapsApiKey $GOOGLE_MAPS_API_KEY" "$INFO_PLIST"
else
  /usr/libexec/PlistBuddy -c "Add :GoogleMapsApiKey string $GOOGLE_MAPS_API_KEY" "$INFO_PLIST"
fi

# Update AdMob App ID (GADApplicationIdentifier)
if /usr/libexec/PlistBuddy -c "Print :GADApplicationIdentifier" "$INFO_PLIST" &>/dev/null; then
  /usr/libexec/PlistBuddy -c "Set :GADApplicationIdentifier $ADMOB_APP_ID" "$INFO_PLIST"
else
  /usr/libexec/PlistBuddy -c "Add :GADApplicationIdentifier string $ADMOB_APP_ID" "$INFO_PLIST"
fi

echo "Info.plist updated successfully!" 