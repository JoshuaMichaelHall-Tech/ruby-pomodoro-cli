# Ruby Pomodoro CLI

A powerful, terminal-based Pomodoro timer with session tracking, productivity analytics, and deep work modes. Designed for developers who prefer terminal-centric workflows with tmux integration.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

**⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Advanced Features](#advanced-features)
- [Analytics](#analytics)
- [Terminal Integration](#terminal-integration)
- [Privacy and Data](#privacy-and-data)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## 🔍 Overview

Ruby Pomodoro CLI is a productivity tool designed for developers who prefer a terminal-centric workflow. It implements the Pomodoro Technique - a time management method that uses focused work sessions separated by breaks - with additional features for deep work, analytics, and seamless terminal integration.

### Learning Objectives
- Implement effective CLI design in Ruby
- Practice object-oriented programming principles
- Develop productivity tracking and analytics tools
- Create seamless terminal environment integration

## ✨ Features

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

## 💻 Technology Stack
- **Language**: Ruby 3.0+
- **Dependencies**: Standard library only (csv, date, fileutils, io/console, optparse)
- **Environment**: zsh, tmux

## 📂 Project Structure
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
├── LICENSE.md              # MIT License
├── .gitignore              # Git ignore file
├── ISSUE_TEMPLATE.md       # Template for GitHub issues
├── PULL_REQUEST_TEMPLATE.md# Template for pull requests
└── README.md               # This file
```

## 🚀 Installation

### Prerequisites
- Ruby 3.0 or higher
- zsh shell
- Git (for updates)
- tmux (optional, for status integration)

### Quick Install

```zsh
# Clone the repository
git clone https://github.com/joshuamichaelhall-tech/ruby-pomodoro-cli.git
cd ruby-pomodoro-cli

# Make the install script executable
chmod +x install.sh

# Run the installation
./install.sh

# Apply changes to your current session
source ~/.zshrc
```

### What the Installation Does

The installation script:
- Creates necessary directories (`~/.pomodoro_logs`, `~/.local/bin`, `~/.local/lib`)
- Sets up executable files
- Creates symlinks to make the commands available system-wide
- Adds convenient aliases to your `.zshrc` (`pom` and `poma`)
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

The uninstall script will prompt you about keeping or removing your log files.

## 🎮 Usage

### Starting a Pomodoro Session

```zsh
pomodoro [options]
# or use the alias
pom [options]
```

Options:
- `-w, --work-time MINUTES`: Work session duration (default: 25)
- `-b, --break-time MINUTES`: Short break duration (default: 5)
- `-l, --long-break MINUTES`: Long break duration (default: 15)
- `-s, --sessions NUMBER`: Sessions before a long break (default: 4)
- `-d, --deep-work`: Enable Deep Work mode (3 sets of 3 sessions)
- `-h, --help`: Show help message

### Basic Workflow

1. Start a new session with `pomodoro`
2. Enter the project/course you're working on
3. Work until the timer ends
4. Enter what you accomplished during the session
5. Take a break
6. Repeat until your work is complete

### Keyboard Controls

While a timer is running:
- `p`: Pause or resume the current timer
- `s`: Skip the current break (only available during breaks)
- `q`: Quit the current timer

## 🧠 Advanced Features

### Deep Work Mode

For extended focus sessions:

```zsh
pomodoro --deep-work
# or
pom -d
```

This mode structures your work into:

- **3 Sets** (First, Second, Third)
- **Each set consists of**:
  - 60-minute session ("initium")
  - 5-minute break
  - 55-minute session ("medius")
  - 10-minute break
  - 50-minute session ("fines")

### Pausing and Resuming

When you pause a timer:
1. The countdown freezes and displays "PAUSED"
2. The tmux status bar shows a pause indicator
3. Press 'p' again to resume where you left off
4. Total session duration is adjusted to account for pause time

### Custom Session Lengths

For special tasks that need different timing:

```zsh
# 45-minute work sessions with 10-minute breaks
pomodoro -w 45 -b 10

# 30-minute work sessions with 8-minute breaks and 20-minute long breaks every 3 sessions
pomodoro -w 30 -b 8 -l 20 -s 3
```

## 📊 Analytics

Analyze your productivity patterns with the built-in log analyzer:

```zsh
pomodoro_analyze [options]
# or use the alias
poma [options]
```

Options:
- `-d, --directory DIR`: Log directory (default: ~/.pomodoro_logs)
- `-o, --output FILE`: Output file (default: pomodoro_summary.csv)
- `-s, --start-date DATE`: Start date in YYYY-MM-DD format
- `-e, --end-date DATE`: End date in YYYY-MM-DD format (default: today)
- `--public-summary`: Generate a public summary without personal details
- `--public-output FILE`: Public summary output file (default: pomodoro_public_stats.md)
- `-h, --help`: Show help message

### Example Analytics Usage

```zsh
# Analyze last week's sessions
poma -s 2025-04-01 -e 2025-04-07

# Generate a shareable summary without personal details
poma --public-summary
```

### Log Format

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

## 🖥️ Terminal Integration

### ZSH Configuration

The installation script automatically adds these to your `.zshrc`:

```zsh
# Pomodoro timer aliases
alias pom="pomodoro"
alias poma="pomodoro_analyze"
```

### Tmux Integration

The installation script adds this to your `.tmux.conf`:

```
# Pomodoro status in tmux
set -g status-right "#[fg=green]#(cat ~/.pomodoro_current 2>/dev/null || echo 'No pomodoro')#[default] | %H:%M"
```

This displays your current Pomodoro status in the tmux status bar.

## 🔒 Privacy and Data

### Your Data Stays Private

- **Local Storage**: All logs are stored locally in `~/.pomodoro_logs/`
- **No Cloud Sync**: The application never uploads your activity data
- **Git Protection**: The `.gitignore` file prevents logs from being committed

### Sharing Your Progress (Optional)

If you want to share your progress publicly while keeping your data private:

```zsh
# Generate a public summary (removes specific task details)
pomodoro_analyze --public-summary
```

This creates a `pomodoro_public_stats.md` file with:
- Total days tracked
- Total sessions completed
- Total and average focus time
- Current streak information
- Weekly averages
- A simple ASCII chart of recent activity

## 🛠️ Development

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please use the provided pull request template when submitting changes.

### Reporting Issues

Use the Issue Template provided in the repository when reporting bugs or requesting features.

## 🗺️ Roadmap

See the [enhancement-roadmap.md](enhancement-roadmap.md) file for planned features and improvements.

Highlights include:
- Data visualization for productivity trends
- Task integration and tagging
- Enhanced tmux integration
- Interactive reports and filtering
- Third-party API integration
- ML-based productivity insights

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](license.md) file for details.

## 👏 Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.
