#!/bin/bash

# Function to display a header
function display_header() {
  echo "======================================"
  echo "$1"
  echo "======================================"
}

# Function to copy environment file
function copy_env_file() {
  ENV=$1
  
  if [ -f ".env.$ENV" ]; then
    echo "Environment file .env.$ENV already exists."
  else
    echo "Creating .env.$ENV file..."
    cp -f .env_examples/env.$ENV .env.$ENV
    echo "Created .env.$ENV file."
  fi
}

# Main script
display_header "Madwell Environment Setup Script"

echo "This script will setup the environment for Madwell app."
echo ""
echo "1. Development environment"
echo "2. Staging environment"
echo "3. Production environment"
echo "4. Setup all environments"
echo "5. Exit"
echo ""

read -p "Select an option (1-5): " choice

case $choice in
  1)
    display_header "Setting up Development environment"
    copy_env_file "dev"
    echo "Running development environment..."
    flutter run --flavor dev --dart-define=ENV=dev
    ;;
  2)
    display_header "Setting up Staging environment"
    copy_env_file "staging"
    echo "Running staging environment..."
    flutter run --flavor staging --dart-define=ENV=staging
    ;;
  3)
    display_header "Setting up Production environment"
    copy_env_file "prod"
    echo "Running production environment..."
    flutter run --flavor prod --dart-define=ENV=prod
    ;;
  4)
    display_header "Setting up all environments"
    copy_env_file "dev"
    copy_env_file "staging"
    copy_env_file "prod"
    echo "All environment files created."
    ;;
  5)
    display_header "Exiting"
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac 