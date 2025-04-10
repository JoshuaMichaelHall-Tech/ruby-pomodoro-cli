#!/bin/zsh
# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall
# 
# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

# Ensure we're using zsh
if [ -z "$ZSH_VERSION" ]; then
  echo "This script must be run with zsh"
  exit 1
fi

# Define installation paths
LOCAL_BIN="$HOME/.local/bin"
LOCAL_LIB="$HOME/.local/lib"
STATUS_FILE="$HOME/.pomodoro_current"
ZSHRC="$HOME/.zshrc"
TMUX_CONF="$HOME/.tmux.conf"
LOG_DIR="$HOME/.pomodoro_logs"

echo "Ruby Pomodoro CLI Uninstaller"
echo "-------------------------"

# Confirm uninstallation
read -q "CONFIRM?Are you sure you want to uninstall Ruby Pomodoro CLI? (y/n) "
echo ""

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
  echo "Uninstallation cancelled."
  exit 0
fi

# Ask about log files
read -q "LOGS?Do you want to keep your log files? (y/n) "
echo ""
KEEP_LOGS=$LOGS

# Remove binary symlinks
echo "Removing program files..."
if [ -L "${LOCAL_BIN}/pomodoro" ]; then
  rm "${LOCAL_BIN}/pomodoro"
  echo "Removed ${LOCAL_BIN}/pomodoro"
fi

if [ -L "${LOCAL_BIN}/pomodoro_analyze" ]; then
  rm "${LOCAL_BIN}/pomodoro_analyze"
  echo "Removed ${LOCAL_BIN}/pomodoro_analyze"
fi

# Remove library symlinks
if [ -L "${LOCAL_LIB}/pomodoro-timer.rb" ]; then
  rm "${LOCAL_LIB}/pomodoro-timer.rb"
  echo "Removed ${LOCAL_LIB}/pomodoro-timer.rb"
fi

if [ -L "${LOCAL_LIB}/log-analyzer.rb" ]; then
  rm "${LOCAL_LIB}/log-analyzer.rb"
  echo "Removed ${LOCAL_LIB}/log-analyzer.rb"
fi

# Remove tmux status file
if [ -f "$STATUS_FILE" ]; then
  rm "$STATUS_FILE"
  echo "Removed $STATUS_FILE"
fi

# Remove log files if requested
if [[ ! $KEEP_LOGS =~ ^[Yy]$ ]]; then
  if [ -d "$LOG_DIR" ]; then
    rm -rf "$LOG_DIR"
    echo "Removed log directory at $LOG_DIR"
  fi
else
  echo "Keeping log files in $LOG_DIR"
fi

# Clean up .zshrc aliases
if [ -f "$ZSHRC" ]; then
  echo "Removing aliases from $ZSHRC..."
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  
  # Filter out pomodoro-related lines
  grep -v "# Pomodoro timer aliases" "$ZSHRC" | grep -v "alias pom=" | grep -v "alias poma=" > "$TEMP_FILE"
  
  # Replace original with filtered content
  mv "$TEMP_FILE" "$ZSHRC"
  echo "Removed pomodoro aliases from $ZSHRC"
fi

# Clean up tmux configuration
if [ -f "$TMUX_CONF" ]; then
  echo "Removing tmux integration from $TMUX_CONF..."
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  
  # Filter out pomodoro-related lines
  grep -v "# Pomodoro status in tmux" "$TMUX_CONF" | grep -v "pomodoro_current" > "$TEMP_FILE"
  
  # Replace original with filtered content
  mv "$TEMP_FILE" "$TMUX_CONF"
  echo "Removed pomodoro configuration from $TMUX_CONF"
fi

echo ""
echo "Uninstallation complete!"
echo "You may need to restart your terminal for all changes to take effect."

exit 0