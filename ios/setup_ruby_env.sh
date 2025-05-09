#!/bin/bash

# This script ensures all required Ruby gems are installed
# and bundler is set up correctly

# Install specific bundler version if needed
if ! gem list bundler -v 2.3.27 --installed > /dev/null; then
  echo "Installing bundler 2.3.27..."
  gem install bundler -v 2.3.27
fi

# Install xcodeproj gem if not present
if ! gem list xcodeproj --installed > /dev/null; then
  echo "Installing xcodeproj gem..."
  gem install xcodeproj
fi

# Install cocoapods if not present
if ! gem list cocoapods --installed > /dev/null; then
  echo "Installing cocoapods gem..."
  gem install cocoapods
fi

# Display installed gems for debugging
echo "Installed gems:"
gem list bundler
gem list xcodeproj
gem list cocoapods

echo "Ruby environment setup complete" 