# Ruby Pomodoro CLI

**⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

A terminal-based Pomodoro timer with session tracking and productivity analytics. Integrates with tmux and terminal-centric workflows.

## Learning Objectives
- Implement effective CLI design in Ruby
- Practice object-oriented programming principles
- Develop productivity tracking and analytics tools
- Create seamless terminal environment integration

## Features

- **Session Tracking**: Records project information, session duration, and accomplishments
- **Customizable Timers**: Adjust work and break durations to fit your workflow
- **Deep Work Mode**: Structured sets of longer focused sessions for complex tasks
- **Daily Logs**: Automatically creates date-based logs for easy tracking
- **Analytics**: Generates summaries and statistics from your session logs
- **Terminal Integration**: Designed for terminal-centric workflows with macOS/Linux
- **Pause & Resume**: Pause any timer session or break with a simple keystroke
- **Skip Breaks**: Option to skip break periods when you're in a flow state
- **Session Control**: Easy-to-use keyboard controls displayed directly in the interface
- **Privacy Controls**: Generate shareable statistics without exposing personal task details

## Technology Stack
- Language: Ruby 3.0+
- Dependencies: Standard library only (csv, date, fileutils, io/console, optparse)
- Environment: zsh, tmux

## Project Structure
```
ruby-pomodoro-cli/
├── lib/                    # Core functionality
│   ├── pomodoro-timer.rb   # The main Pomodoro timer
│   └── log-analyzer.rb     # Analytics utility
├── bin/                    # Executable scripts
│   ├── pomodoro            # Runner for timer
│   └── pomodoro_analyze    # Runner for log analyzer
├── install.sh              # Installation script
├── uninstall.sh            # Uninstallation script
├── update.sh               # Update script
├── LICENSE                 # MIT License
├── .gitignore              # Git ignore file
├── ISSUE_TEMPLATE.md       # Template for GitHub issues
├── PULL_REQUEST_TEMPLATE.md# Template for pull requests
└── README.md               # This file
```

## Installation and Management

### Installation

The Pomodoro CLI includes a robust installation system that handles first-time installations and updates:

```zsh
# Clone the repository
git clone https://github.com/joshuamichaelhall-tech/ruby-pomodoro-cli.git
cd ruby-pomodoro-cli

# Make the install script executable
chmod +x install.sh

# Run the installation
./install.sh
```

The installation script:
- Creates necessary directories
- Sets up executable files
- Creates symlinks to make the commands available system-wide
- Adds convenient aliases to your `.zshrc`
- Integrates with tmux if available
- Preserves any existing configurations

### Updating

To check for and apply updates:

```zsh
# Navigate to your installation directory
cd path/to/ruby-pomodoro-cli

# Make the update script executable (first time only)
chmod +x update.sh

# Run the updater
./update.sh
```

The update script:
- Checks if new versions are available
- Pulls the latest changes from the repository
- Runs the installer to apply updates
- Preserves your custom configurations

### Uninstalling

If you need to remove the Pomodoro CLI:

```zsh
# Navigate to your installation directory
cd path/to/ruby-pomodoro-cli

# Make the uninstall script executable (first time only)
chmod +x uninstall.sh

# Run the uninstaller
./uninstall.sh
```

The uninstall script:
- Removes all symlinks and program files
- Cleans up your `.zshrc` and tmux configuration
- Optionally preserves your log files
- Leaves your repository intact in case you want to reinstall later

After uninstalling, you may want to remove the repository directory if you no longer need it:

```zsh
# Optional: remove the repository after uninstalling
cd ..
rm -rf ruby-pomodoro-cli
```

## Usage

### Starting a Pomodoro Session

```zsh
pomodoro [options]
```

Options:
- `-w, --work-time MINUTES`: Work session duration (default: 25)
- `-b, --break-time MINUTES`: Short break duration (default: 5)
- `-l, --long-break MINUTES`: Long break duration (default: 15)
- `-s, --sessions NUMBER`: Sessions before a long break (default: 4)
- `-d, --deep-work`: Enable Deep Work mode (3 sets of 3 sessions)
- `-h, --help`: Show help message

### Keyboard Controls

While a timer is running:
- `p`: Pause or resume the current timer
- `s`: Skip the current break (only available during breaks)
- `q`: Quit the current timer

The controls are displayed in the timer interface for easy reference.

### Deep Work Mode

The Pomodoro CLI includes a special Deep Work mode designed for extended focus sessions:

```zsh
pomodoro --deep-work
```

This mode structures your work into:

- **3 Sets** (First, Second, Third)
- **Each set consists of**:
  - 60-minute session ("initium")
  - 5-minute break
  - 55-minute session ("medius")
  - 10-minute break
  - 50-minute session ("fines")

Deep Work mode is ideal for:
- Complex problem-solving tasks
- Writing or coding projects requiring sustained focus
- Learning new concepts that benefit from immersion

### Pausing and Resuming

When you pause a timer:
1. The countdown freezes and displays "PAUSED"
2. The tmux status bar shows a pause indicator
3. Press 'p' again to resume where you left off
4. Total session duration is adjusted to account for pause time

### Skipping Breaks

During any break period:
1. Press 's' to immediately end the break
2. The next work session will start right away
3. This feature is useful when you're in a flow state and want to continue working

### Analyzing Your Logs

```zsh
pomodoro_analyze [options]
```

Options:
- `-d, --directory DIR`: Log directory (default: ~/.pomodoro_logs)
- `-o, --output FILE`: Output file (default: pomodoro_summary.csv)
- `-s, --start-date DATE`: Start date in YYYY-MM-DD format
- `-e, --end-date DATE`: End date in YYYY-MM-DD format (default: today)
- `--public-summary`: Generate a public summary without personal details
- `--public-output FILE`: Public summary output file (default: pomodoro_public_stats.md)
- `-h, --help`: Show help message

## Privacy and Data Sharing

The Pomodoro CLI is designed to respect your privacy while enabling progress tracking and collaboration:

### Your Data Stays Private

- **Local Storage**: All your pomodoro logs are stored locally in `~/.pomodoro_logs/` on your machine
- **No Cloud Sync**: The application never uploads your activity data anywhere
- **Git Protection**: The `.gitignore` file ensures logs and personal data won't be committed to Git repositories

### Sharing Your Progress (Optional)

If you want to share your progress publicly while keeping your data private:

#### Option 1: Aggregated Stats Only
```zsh
# Generate a summary report
pomodoro_analyze

# Create a public summary (removes specific task details)
pomodoro_analyze --public-summary
```

#### Option 2: GitHub Gist for Challenge Updates
- Create a daily/weekly summary screenshot
- Post it as a GitHub Gist or in your repository's wiki
- Never share the raw CSV files with task details

#### Option 3: Track Streaks in Your Repository
Add this to your README.md:
```markdown
## My Pomodoro Challenge Progress
- Current streak: 12 days
- Total pomodoros: 147
- Weekly average: 27
- Last updated: April 3, 2025
```

### For Open Source Contributors

If you're contributing to this project, please:

1. **Never commit log files** or personal data
2. **Keep the `.gitignore` file updated** with any new data file patterns
3. **Respect the separation** between the application and user data

## Log Format

Individual session logs are stored in `~/.pomodoro_logs/YYYY-MM-DD.csv` with the following fields:
- Date
- Project
- Session number
- Duration (in seconds)
- Update (what you accomplished)

The summary CSV contains:
- Date
- Project
- Total sessions
- Total time (minutes)
- Average session length (minutes)
- Updates (consolidated from all sessions)

## Integration with Other Tools

### ZSH Configuration

Add this to your `.zshrc` to create a convenient alias if you used manual install (install.sh adds this automatically!):

```zsh
# Pomodoro timer alias
alias pom='pomodoro'
alias poma='pomodoro_analyze'
```

### Tmux Integration

Add this to your `.tmux.conf` to show your current Pomodoro status in the tmux status bar if you used manual install (install.sh adds this automatically!):

```
# Pomodoro status in tmux
set -g status-right "#[fg=green]#(cat ~/.pomodoro_current 2>/dev/null || echo 'No pomodoro')#[default] | %H:%M"
```

## Development Process

This project implements a mastery-based approach to Ruby development, focusing on:

1. Object-oriented design principles
2. Command-line interface best practices
3. File I/O and data persistence
4. Integration with terminal workflow tools

The tool is designed to be minimalist yet powerful, with a focus on terminal-centric workflows using zsh and tmux.

## Related Repositories

- [terminal-setup](https://github.com/JoshuaMichaelHall-Tech/terminal-setup) - A highly customized terminal-based development environment using Zsh, Neovim, tmux, and command-line tools optimized for software engineering workflows.

## Future Work

- Add RSpec tests for core functionality
- Create a visualization tool for productivity trends
- Implement integrations with task management systems
- Add support for different Pomodoro techniques

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## License

[MIT License](LICENSE)
