#!/bin/zsh
# Update script for Ruby Pomodoro CLI

# Ensure we're using zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "This script must be run with zsh"
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if git is installed
if ! command_exists git; then
  echo "Git is required for updates but not installed. Please install Git first."
  exit 1
fi

# Define paths
INSTALL_DIR="$(pwd)"
VERSION_FILE="${INSTALL_DIR}/.version"
CURRENT_VERSION="0.0.0"

echo "Ruby Pomodoro CLI Updater"
echo "------------------------"

# Check current version
if [ -f "$VERSION_FILE" ]; then
  CURRENT_VERSION=$(cat "$VERSION_FILE")
  echo "Current version: $CURRENT_VERSION"
else
  echo "No version information found. This appears to be a new installation."
fi

# Check if we're in a git repository
if [ -d ".git" ]; then
  echo "Checking for updates..."
  
  # Fetch the latest changes
  git fetch
  
  # Check if we're behind the remote
  BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null)
  
  if [ "$BEHIND" -gt 0 ]; then
    echo "Updates available! Found $BEHIND new commits."
    
    # Prompt for update
    read -q "CONFIRM?Do you want to update now? (y/n) "
    echo ""
    
    if [[ $CONFIRM =~ ^[Yy]$ ]]; then
      echo "Backing up customizations..."
      
      # Pull the latest changes
      echo "Pulling updates..."
      git pull origin main
      
      if [ $? -eq 0 ]; then
        echo "Update succeeded. Running installer to apply changes..."
        # Run the installer to update symlinks and configurations
        ./install.sh
        echo "Update complete!"
      else
        echo "Failed to update. Please resolve any git conflicts and try again."
        exit 1
      fi
    else
      echo "Update cancelled."
    fi
  else
    echo "No updates available. You're running the latest version."
  fi
else
  echo "This doesn't appear to be a git repository."
  echo "For automatic updates, please clone the repository using git:"
  echo "git clone https://github.com/joshuamichaelhall-tech/ruby-pomodoro-cli.git"
fi

exit 0
