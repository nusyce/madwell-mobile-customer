#!/bin/bash

# Test environment configuration script

# Function to display a header
function display_header() {
  echo "======================================"
  echo "$1"
  echo "======================================"
}

# Function to run flutter in a specific environment
function run_env_test() {
  ENV=$1
  display_header "Testing $ENV environment"
  
  # Run the app with the specified environment
  echo "Running: flutter run --dart-define=ENV=$ENV --flavor $ENV"
  flutter run --dart-define=ENV=$ENV --flavor $ENV
}

# Main script
display_header "Madwell Environment Test Script"

echo "This script will test the environment configuration for Madwell app."
echo "Make sure you have created the .env files in the project root."
echo ""
echo "1. Development"
echo "2. Staging"
echo "3. Production"
echo "4. Exit"
echo ""

read -p "Select an environment to test (1-4): " choice

case $choice in
  1)
    run_env_test "dev"
    ;;
  2)
    run_env_test "staging"
    ;;
  3)
    run_env_test "prod"
    ;;
  4)
    display_header "Exiting"
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac 