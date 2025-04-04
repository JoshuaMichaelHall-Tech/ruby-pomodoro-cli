#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'date'
require 'fileutils'
require 'io/console'
require 'optparse'

class PomodoroTimer
  DEFAULT_WORK_TIME = 25 * 60
  DEFAULT_BREAK_TIME = 5 * 60
  DEFAULT_LONG_BREAK_TIME = 15 * 60
  DEFAULT_SESSIONS_BEFORE_LONG_BREAK = 4
  
  attr_reader :log_file, :work_time, :break_time, :long_break_time, :sessions_before_long_break

  def initialize(options = {})
    @work_time = options[:work_time] || DEFAULT_WORK_TIME
    @break_time = options[:break_time] || DEFAULT_BREAK_TIME
    @long_break_time = options[:long_break_time] || DEFAULT_LONG_BREAK_TIME
    @sessions_before_long_break = options[:sessions_before_long_break] || DEFAULT_SESSIONS_BEFORE_LONG_BREAK
    
    # Create log directory if it doesn't exist
    @log_dir = File.join(Dir.home, '.pomodoro_logs')
    FileUtils.mkdir_p(@log_dir) unless Dir.exist?(@log_dir)
    
    # Define log file path with today's date
    @log_file = File.join(@log_dir, "#{Date.today.strftime('%Y-%m-%d')}.csv")
    
    # Create log file with headers if it doesn't exist
    unless File.exist?(@log_file)
      CSV.open(@log_file, 'w') do |csv|
        csv << ['date', 'project', 'session', 'duration', 'update']
      end
    end
  end

  def start
    # Initialize status file for tmux integration
    status_file = File.join(Dir.home, '.pomodoro_current')
    File.write(status_file, "🍅 Starting")
    
    puts "\n🍅 Welcome to the Pomodoro Timer 🍅"
    puts "----------------------------------------"
    puts "Work time: #{format_time(work_time)}"
    puts "Break time: #{format_time(break_time)}"
    puts "Long break time: #{format_time(long_break_time)}"
    puts "Sessions before long break: #{sessions_before_long_break}"
    puts "----------------------------------------"
    puts "Controls: p = pause/resume, s = skip (break only), q = quit"
    puts "----------------------------------------"
    
    # Get project/course information at the start of the day
    print "\nWhat project/course are you working on today? "
    project = gets.chomp
    
    session_count = 0
    continue = true
    
    while continue
      session_count += 1
      
      # Determine if this is a long break
      is_long_break = (session_count % sessions_before_long_break == 0)
      
      # Start work session
      puts "\n----------------------------------------"
      puts "🍅 Starting session ##{session_count} (#{format_time(work_time)})"
      puts "Project: #{project}"
      puts "Controls: p = pause/resume, q = quit"
      puts "----------------------------------------"
      
      # Run the timer for work session
      start_time = Time.now
      elapsed_time = run_timer(work_time, :work)
      
      # If the timer was quit prematurely, ask if user wants to continue
      if elapsed_time < 0
        print "\nDo you want to continue with the Pomodoro sessions? (y/n): "
        response = gets.chomp.downcase
        continue = (response == 'y' || response == 'yes')
        break unless continue
      end
      
      # Prompt for session update
      puts "\n✏️  Session ##{session_count} complete!"
      print "What did you accomplish in this session? "
      update = gets.chomp
      
      # Log the session
      actual_duration = (elapsed_time < 0) ? (Time.now - start_time).to_i : elapsed_time
      log_session(project, session_count, actual_duration, update)
      
      # Determine break type and time
      break_duration = is_long_break ? long_break_time : break_time
      break_type = is_long_break ? "long break" : "short break"
      
      puts "\n----------------------------------------"
      puts "🕑 Starting #{break_type} (#{format_time(break_duration)})"
      puts "Controls: p = pause/resume, s = skip, q = quit"
      puts "----------------------------------------"
      
      # Run the timer for break
      break_result = run_timer(break_duration, :break)
      
      # Handle break result
      if break_result == :skipped
        puts "\n⏩ Break skipped!"
      elsif break_result < 0
        print "\nDo you want to continue with the Pomodoro sessions? (y/n): "
        response = gets.chomp.downcase
        continue = (response == 'y' || response == 'yes')
        break unless continue
      else
        puts "\n✅ Break complete!"
      end
      
      # Ask if the user wants to continue
      print "Continue with another session? (y/n): "
      response = gets.chomp.downcase
      continue = (response == 'y' || response == 'yes')
    end
    
    puts "\n----------------------------------------"
    puts "🎉 Great work today! You completed #{session_count} pomodoro sessions."
    puts "Your progress has been logged to: #{log_file}"
    puts "----------------------------------------"
    
    # Clean up status file
    File.write(status_file, "No pomodoro")
  end
  
  private
  
  def run_timer(duration, type = :work)
    end_time = Time.now + duration
    status_file = File.join(Dir.home, '.pomodoro_current')
    
    # Variables for pause functionality
    paused = false
    pause_start = nil
    total_pause_time = 0
    
    while Time.now < end_time
      # Calculate current remaining time considering pauses
      current_time = Time.now
      if paused
        # When paused, we don't update the end_time yet, just show frozen time
        remaining = (end_time - current_time).to_i - total_pause_time
      else
        remaining = (end_time - current_time).to_i
      end
      
      mins, secs = remaining.divmod(60)
      
      # Create status line with controls
      status_line = paused ? 
        "⏸️  #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')} PAUSED | p = resume, q = quit" :
        "⏱️  #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')} remaining | p = pause"
      
      if type == :break && !paused
        status_line += ", s = skip"
      end
      
      status_line += ", q = quit"
      
      # Update status file for tmux integration
      if paused
        File.write(status_file, "🍅 ⏸️ PAUSED")
      else
        File.write(status_file, "🍅 #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')}")
      end
      
      # Clear line and print status
      print "\r" + " " * 80 # Clear the line with spaces
      print "\r#{status_line}"
      
      # Check for key input
      if IO.select([STDIN], nil, nil, 0)
        key = STDIN.getch.downcase
        
        case key
        when 'p' # Pause/resume
          if paused
            # Resume timer
            paused = false
            total_pause_time += (Time.now - pause_start).to_i
            puts "\n▶️  Timer resumed"
          else
            # Pause timer
            paused = true
            pause_start = Time.now
            puts "\n⏸️  Timer paused - press 'p' to resume, 'q' to quit"
          end
        when 's' # Skip (break only)
          if type == :break && !paused
            puts "\n⏩ Skipping break!"
            return :skipped
          end
        when 'q' # Quit
          puts "\n⏹️  Timer stopped."
          File.write(status_file, "No pomodoro")
          return -1 # Return a negative value to indicate quit
        end
      end
      
      # Skip the sleep if paused
      sleep 1 unless paused
    end
    
    # Reset status file
    File.write(status_file, "No pomodoro")
    
    # Play a sound to notify the user when the time is up
    puts "\n\a" # Terminal bell
    
    # Return the actual duration accounting for pauses
    (duration - total_pause_time)
  end
  
  def log_session(project, session_number, duration, update)
    CSV.open(log_file, 'a') do |csv|
      csv << [Date.today.strftime('%Y-%m-%d'), project, session_number, duration, update]
    end
  end
  
  def format_time(seconds)
    mins, secs = seconds.divmod(60)
    "#{mins}:#{secs.to_s.rjust(2, '0')}"
  end
end

# Parse command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: pomodoro [options]"
  
  opts.on("-w", "--work-time MINUTES", Integer, "Work session duration in minutes (default: 25)") do |w|
    options[:work_time] = w * 60
  end
  
  opts.on("-b", "--break-time MINUTES", Integer, "Short break duration in minutes (default: 5)") do |b|
    options[:break_time] = b * 60
  end
  
  opts.on("-l", "--long-break MINUTES", Integer, "Long break duration in minutes (default: 15)") do |l|
    options[:long_break_time] = l * 60
  end
  
  opts.on("-s", "--sessions NUMBER", Integer, "Number of sessions before a long break (default: 4)") do |s|
    options[:sessions_before_long_break] = s
  end
  
  opts.on("-h", "--help", "Show help message") do
    puts opts
    exit
  end
end.parse!

# Start the Pomodoro timer
PomodoroTimer.new(options).start