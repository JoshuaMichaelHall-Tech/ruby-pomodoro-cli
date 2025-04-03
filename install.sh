#!/bin/zsh
# Installation script for Ruby Pomodoro CLI

# Ensure we're using zsh as per user preference
if [ -z "$ZSH_VERSION" ]; then
  echo "This script must be run with zsh"
  exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for Ruby
if ! command_exists ruby; then
  echo "Ruby is required but not installed. Please install Ruby first."
  exit 1
fi

echo "Installing Ruby Pomodoro CLI..."

# Create directory structure
mkdir -p "$HOME/.pomodoro_logs"
mkdir -p "$HOME/.local/bin"

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
chmod +x lib/pomodoro-timer.rb
chmod +x lib/log-analyzer.rb

# Create symlinks
echo "Creating symlinks..."
# Create lib directory in ~/.local if it doesn't exist
mkdir -p "$HOME/.local/lib"

# Symlink the actual library files
ln -sf "$(pwd)/lib/pomodoro-timer.rb" "$HOME/.local/lib/pomodoro-timer.rb"
ln -sf "$(pwd)/lib/log-analyzer.rb" "$HOME/.local/lib/log-analyzer.rb"

# Symlink the bin files
ln -sf "$(pwd)/bin/pomodoro" "$HOME/.local/bin/pomodoro"
ln -sf "$(pwd)/bin/pomodoro_analyze" "$HOME/.local/bin/pomodoro_analyze"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "Adding ~/.local/bin to your PATH in .zshrc"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

# Add aliases to .zshrc if they don't exist
if ! grep -q "alias pom=" "$HOME/.zshrc"; then
  echo "Adding aliases to .zshrc"
  echo '# Pomodoro timer aliases' >> "$HOME/.zshrc"
  echo 'alias pom="pomodoro"' >> "$HOME/.zshrc"
  echo 'alias poma="pomodoro_analyze"' >> "$HOME/.zshrc"
fi

# Add tmux integration if tmux is installed
if command_exists tmux; then
  echo "Adding tmux integration..."
  
  # Check if the configuration already exists
  if ! grep -q "pomodoro_current" "$HOME/.tmux.conf" 2>/dev/null; then
    echo '# Pomodoro status in tmux' >> "$HOME/.tmux.conf"
    echo 'set -g status-right "#[fg=green]#(cat ~/.pomodoro_current 2>/dev/null || echo \"No pomodoro\")#[default] | %H:%M"' >> "$HOME/.tmux.conf"
  fi
fi

echo "Installation complete!"
echo "You can now run 'pomodoro' to start a new Pomodoro session."
echo "Use 'pomodoro_analyze' to generate summaries from your logs."
echo ""
echo "To apply the new aliases and PATH changes, restart your terminal or run:"
echo "source ~/.zshrc"

exit 0
