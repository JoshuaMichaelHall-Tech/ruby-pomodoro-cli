#!/bin/zsh
# Installation script for Terminal Pomodoro

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

echo "Installing Terminal Pomodoro..."

# Create directory structure
mkdir -p "$HOME/.pomodoro_logs"

# Make scripts executable
chmod +x pomodoro.rb
chmod +x pomodoro_analyze.rb

# Create symlinks
echo "Creating symlinks..."
ln -sf "$(pwd)/pomodoro.rb" "$HOME/.local/bin/pomodoro"
ln -sf "$(pwd)/pomodoro_analyze.rb" "$HOME/.local/bin/pomodoro_analyze"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "Adding ~/.local/bin to your PATH in .zshrc"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  
  # Source the updated .zshrc
  source "$HOME/.zshrc"
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
