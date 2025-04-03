# Terminal Pomodoro Timer

A simple, command-line based Pomodoro timer that tracks your work sessions and provides detailed logging for productivity analysis.

## Features

- **Session Tracking**: Records project information, session duration, and accomplishments
- **Customizable Timers**: Adjust work and break durations to fit your workflow
- **Daily Logs**: Automatically creates date-based logs for easy tracking
- **Analytics**: Generates summaries and statistics from your session logs
- **Terminal Integration**: Designed for terminal-centric workflows with macOS/Linux

## Installation

1. Clone this repository:
```
git clone https://github.com/your-username/terminal-pomodoro.git
cd terminal-pomodoro
```

2. Make the scripts executable:
```
chmod +x pomodoro.rb
chmod +x pomodoro_analyze.rb
```

3. Optionally, create symlinks to add the commands to your path:
```
ln -s "$(pwd)/pomodoro.rb" /usr/local/bin/pomodoro
ln -s "$(pwd)/pomodoro_analyze.rb" /usr/local/bin/pomodoro_analyze
```

## Usage

### Starting a Pomodoro Session

```
pomodoro [options]
```

Options:
- `-w, --work-time MINUTES`: Work session duration (default: 25)
- `-b, --break-time MINUTES`: Short break duration (default: 5)
- `-l, --long-break MINUTES`: Long break duration (default: 15)
- `-s, --sessions NUMBER`: Sessions before a long break (default: 4)
- `-h, --help`: Show help message

### Analyzing Your Logs

```
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

```
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

## License

MIT
