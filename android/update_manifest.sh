#!/bin/bash

# Script to update AndroidManifest.xml with values from .env file
# Usage: ./update_manifest.sh [env_name]
# Example: ./update_manifest.sh dev

# Default to dev environment if not specified
ENV_NAME=${1:-dev}
ENV_FILE="../.env.$ENV_NAME"
MANIFEST_FILE="app/src/main/AndroidManifest.xml"

echo "===== Updating AndroidManifest.xml from $ENV_FILE ====="

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file $ENV_FILE not found!"
  echo "Make sure to run setup_env.sh first to create the environment files."
  exit 1
fi

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "Error: AndroidManifest.xml file not found at $MANIFEST_FILE!"
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
ADMOB_APP_ID=$(read_env_var "ADMOB_APP_ID" "ca-app-pub-3940256099942544~3347511713")
APP_NAME=$(read_env_var "APP_NAME" "Madwell")
PACKAGE_NAME=$(read_env_var "ANDROID_PACKAGE_NAME" "app.madwell.pro.customer")

echo "Updating AndroidManifest.xml with the following values:"
echo "- Google Maps API Key: ${GOOGLE_MAPS_API_KEY:0:5}... (truncated for security)"
echo "- AdMob App ID: $ADMOB_APP_ID"

# Create a backup of the original file
cp "$MANIFEST_FILE" "${MANIFEST_FILE}.bak"

# Update Google Maps API Key in AndroidManifest.xml
if [ ! -z "$GOOGLE_MAPS_API_KEY" ]; then
  echo "Updating Google Maps API Key..."
  sed -i.tmp "s|android:name=\"com.google.android.geo.API_KEY\"[[:space:]]*android:value=\"[^\"]*\"|android:name=\"com.google.android.geo.API_KEY\" android:value=\"$GOOGLE_MAPS_API_KEY\"|g" "$MANIFEST_FILE"
  rm -f "${MANIFEST_FILE}.tmp"
fi

# Update AdMob App ID in AndroidManifest.xml
if [ ! -z "$ADMOB_APP_ID" ]; then
  echo "Updating AdMob App ID..."
  sed -i.tmp "s|android:name=\"com.google.android.gms.ads.APPLICATION_ID\"[[:space:]]*android:value=\"[^\"]*\"|android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"$ADMOB_APP_ID\"|g" "$MANIFEST_FILE"
  rm -f "${MANIFEST_FILE}.tmp"
fi

echo "AndroidManifest.xml updated successfully!" 