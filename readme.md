# Ruby Pomodoro CLI

A terminal-based Pomodoro timer with session tracking and productivity analytics. Integrates with tmux and terminal-centric workflows.

## Learning Objectives
- Implement effective CLI design in Ruby
- Practice object-oriented programming principles
- Develop productivity tracking and analytics tools
- Create seamless terminal environment integration

## Features

- **Session Tracking**: Records project information, session duration, and accomplishments
- **Customizable Timers**: Adjust work and break durations to fit your workflow
- **Daily Logs**: Automatically creates date-based logs for easy tracking
- **Analytics**: Generates summaries and statistics from your session logs
- **Terminal Integration**: Designed for terminal-centric workflows with macOS/Linux

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
├── LICENSE                 # MIT License
├── .gitignore              # Git ignore file
├── ISSUE_TEMPLATE.md       # Template for GitHub issues
├── PULL_REQUEST_TEMPLATE.md# Template for pull requests
└── README.md               # This file
```

## Installation

1. Clone this repository:
```zsh
git clone https://github.com/joshuamichaelhall-tech/ruby-pomodoro-cli.git
cd ruby-pomodoro-cli
```

2. Run the installation script:
```zsh
chmod +x install.sh
./install.sh
```

3. Or manually install:
```zsh
# Create bin directory if it doesn't exist
mkdir -p bin

# Create runner scripts
echo '#!/usr/bin/env ruby
require_relative "../lib/pomodoro-timer"' > bin/pomodoro

echo '#!/usr/bin/env ruby
require_relative "../lib/log-analyzer"' > bin/pomodoro_analyze

# Make executables
chmod +x bin/pomodoro bin/pomodoro_analyze

# Create symlinks
mkdir -p ~/.local/bin
ln -sf "$(pwd)/bin/pomodoro" ~/.local/bin/pomodoro
ln -sf "$(pwd)/bin/pomodoro_analyze" ~/.local/bin/pomodoro_analyze
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
- `-h, --help`: Show help message

### Analyzing Your Logs

```zsh
pomodoro_analyze [options]
```

Options:
- `-d, --directory DIR`: Log directory (default: ~/.pomodoro_logs)
- `-o, --output FILE`: Output file (default: pomodoro_summary.csv)
- `-s, --start-date DATE`: Start date in YYYY-MM-DD format
- `-e, --end-date DATE`: End date in YYYY-MM-DD format (default: today)
- `-h, --help`: Show help message

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

Add this to your `.zshrc` to create a convenient alias:

```zsh
# Pomodoro timer alias
alias pom='pomodoro'
alias poma='pomodoro_analyze'
```

### Tmux Integration

Add this to your `.tmux.conf` to show your current Pomodoro status in the tmux status bar:

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

- [terminal-setup](https://https://github.com/JoshuaMichaelHall-Tech/terminal-setup) - A highly customized terminal-based development environment using Zsh, Neovim, tmux, and command-line tools optimized for software engineering workflows.

## Future Work

- Add RSpec tests for core functionality
- Create a visualization tool for productivity trends
- Implement integrations with task management systems
- Add support for different Pomodoro techniques

## License

[MIT License](LICENSE)
