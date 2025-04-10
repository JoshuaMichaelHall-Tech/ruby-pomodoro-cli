#!/bin/zsh
# Improved installation script for Ruby Pomodoro CLI
# Handles existing installations and provides update capability

# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall

# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

# Ensure we're using zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "This script must be run with zsh"
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check if a line exists in a file
line_exists() {
  grep -Fq "$1" "$2" 2>/dev/null
}

# Check for Ruby
if ! command_exists ruby; then
  echo "Ruby is required but not installed. Please install Ruby first."
  exit 1
fi

# Define installation paths
INSTALL_DIR="$(pwd)"
LOG_DIR="$HOME/.pomodoro_logs"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_LIB="$HOME/.local/lib"
STATUS_FILE="$HOME/.pomodoro_current"
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.tmux.conf"

# Create required directories
echo "Setting up directories..."
mkdir -p "$LOG_DIR"
mkdir -p "$LOCAL_BIN"
mkdir -p "$LOCAL_LIB"

# Check if bin directory exists, create if needed
if [ ! -d "bin" ]; then
  echo "Creating bin directory and runner scripts..."
  mkdir -p bin
  
  # Create runner for pomodoro timer
  cat > bin/pomodoro << 'EOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

# Add the lib directory to the load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'pomodoro-timer'
EOF

  # Create runner for log analyzer
  cat > bin/pomodoro_analyze << 'EOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

# Add the lib directory to the load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'log-analyzer'
EOF
fi

# Make scripts executable
chmod +x bin/pomodoro
chmod +x bin/pomodoro_analyze
if [ -f "lib/pomodoro-timer.rb" ]; then
  chmod +x lib/pomodoro-timer.rb
fi
if [ -f "lib/log-analyzer.rb" ]; then
  chmod +x lib/log-analyzer.rb
fi

# Create/update symlinks with -f to overwrite existing ones
echo "Creating/updating symlinks..."
ln -sf "${INSTALL_DIR}/lib/pomodoro-timer.rb" "${LOCAL_LIB}/pomodoro-timer.rb"
ln -sf "${INSTALL_DIR}/lib/log-analyzer.rb" "${LOCAL_LIB}/log-analyzer.rb"
ln -sf "${INSTALL_DIR}/bin/pomodoro" "${LOCAL_BIN}/pomodoro"
ln -sf "${INSTALL_DIR}/bin/pomodoro_analyze" "${LOCAL_BIN}/pomodoro_analyze"

# Check if ~/.local/bin is in PATH, add if not present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  if ! line_exists 'export PATH="$HOME/.local/bin:$PATH"' "$ZSHRC"; then
    echo "Adding ~/.local/bin to your PATH in .zshrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
  fi
fi

# Add aliases to .zshrc if they don't exist
ALIAS_BLOCK=$(cat << 'EOF'
# Pomodoro timer aliases
alias pom="pomodoro"
alias poma="pomodoro_analyze"
EOF
)

if ! line_exists "alias pom=" "$ZSHRC"; then
  echo "Adding aliases to .zshrc"
  echo "$ALIAS_BLOCK" >> "$ZSHRC"
fi

# Add tmux integration if tmux is installed
if command_exists tmux; then
  echo "Checking tmux integration..."
  
  TMUX_CONFIG_LINE='set -g status-right "#[fg=green]#(cat ~/.pomodoro_current 2>/dev/null || echo \"No pomodoro\")#[default] | %H:%M"'
  
  # Check if the configuration already exists, add if not
  if [ -f "$TMUX_CONF" ]; then
    if ! line_exists "pomodoro_current" "$TMUX_CONF"; then
      echo '# Pomodoro status in tmux' >> "$TMUX_CONF"
      echo "$TMUX_CONFIG_LINE" >> "$TMUX_CONF"
      echo "Added tmux integration to $TMUX_CONF"
    else
      echo "Tmux integration already configured"
    fi
  else
    echo '# Pomodoro status in tmux' > "$TMUX_CONF"
    echo "$TMUX_CONFIG_LINE" >> "$TMUX_CONF"
    echo "Created $TMUX_CONF with pomodoro integration"
  fi
fi

# Create a version file to track installations
echo "2.0.0" > "${INSTALL_DIR}/.version"

echo "Installation complete!"
echo "You can now run 'pomodoro' to start a new Pomodoro session."
echo "Use 'pomodoro_analyze' to generate summaries from your logs."
echo ""
echo "To apply the new aliases and PATH changes, restart your terminal or run:"
echo "source ~/.zshrc"

exit 0
