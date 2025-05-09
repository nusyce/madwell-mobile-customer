#!/bin/bash

# This script ensures all required Ruby gems are installed
# and bundler is set up correctly for Android fastlane

# Install specific bundler version
echo "Installing bundler 2.3.27..."
gem install bundler -v 2.3.27

# Install fastlane if needed
if ! gem list fastlane --installed > /dev/null; then
  echo "Installing fastlane gem..."
  gem install fastlane -v "~> 2.219.0"
fi

# Check for Gemfile and install dependencies
if [ -f "Gemfile" ]; then
  echo "Installing dependencies from Gemfile..."
  # Update the Gemfile if needed to ensure it has the correct fastlane version
  if ! grep -q "fastlane.*2\.219\.0" Gemfile; then
    echo "Updating fastlane version in Gemfile..."
    sed -i 's/gem "fastlane".*$/gem "fastlane", "~> 2.219.0"/' Gemfile
  fi
  # Install dependencies with specific bundler version
  bundle _2.3.27_ install
else
  # Create a simple Gemfile if it doesn't exist
  echo "Creating Gemfile..."
  echo 'source "https://rubygems.org"' > Gemfile
  echo 'gem "fastlane", "~> 2.219.0"' >> Gemfile
  # Install dependencies with specific bundler version
  bundle _2.3.27_ install
fi

# Display installed gems for debugging
echo "Installed gems:"
gem list bundler
gem list fastlane

echo "Ruby environment setup complete for Android" 