#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall

# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

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
  DEFAULT_DEEP_WORK_MODE = false
  DEFAULT_LOG_DIR = File.join(Dir.home, '.pomodoro_logs')
  
  attr_reader :log_file, :work_time, :break_time, :long_break_time, :sessions_before_long_break, :deep_work_mode

  def initialize(options = {})
    @work_time = options[:work_time] || DEFAULT_WORK_TIME
    @break_time = options[:break_time] || DEFAULT_BREAK_TIME
    @long_break_time = options[:long_break_time] || DEFAULT_LONG_BREAK_TIME
    @sessions_before_long_break = options[:sessions_before_long_break] || DEFAULT_SESSIONS_BEFORE_LONG_BREAK
    @deep_work_mode = options[:deep_work_mode] || DEFAULT_DEEP_WORK_MODE

    # Create log directory if it doesn't exist
    @log_dir = options[:log_dir] || DEFAULT_LOG_DIR
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
    
    # Different welcome message depending on mode
    if @deep_work_mode
      puts "\n🧠 Welcome to the Deep Work Timer 🧠"
      puts "----------------------------------------"
      puts "Session format: 3 sets (First, Second, Third)"
      puts "Each set contains:"
      puts "- initium: 60-minute work session"
      puts "- 5-minute break"
      puts "- medius: 55-minute work session"
      puts "- 10-minute break"
      puts "- fines: 50-minute work session"
      puts "----------------------------------------"
      puts "Controls: p = pause/resume, s = skip (break only),"
      puts "          a = abort (no log), q = quit"
      puts "----------------------------------------"
    else
      puts "\n🍅 Welcome to the Pomodoro Timer 🍅"
      puts "----------------------------------------"
      puts "Work time: #{format_time(work_time)}"
      puts "Break time: #{format_time(break_time)}"
      puts "Long break time: #{format_time(long_break_time)}"
      puts "Sessions before long break: #{sessions_before_long_break}"
      puts "----------------------------------------"
      puts "Controls: p = pause/resume, s = skip (break only),"
      puts "          a = abort (no log), q = quit"
      puts "----------------------------------------"
    end
    
    # Get project/course information at the start of the day
    print "\nWhat project/course are you working on today? "
    project = gets.chomp
    
    if @deep_work_mode
      deep_work_session(project)
    else
      session_count = 0
      continue = true
      completed_count = 0
    
      while continue
        session_count += 1
        
        # Determine if this is a long break
        is_long_break = (session_count % sessions_before_long_break == 0)
        
        # Start work session
        puts "\n----------------------------------------"
        puts "🍅 Starting session ##{session_count} (#{format_time(work_time)})"
        puts "Project: #{project}"
        puts "Controls: p = pause/resume, a = abort (no log), q = quit"
        puts "----------------------------------------"
        
        # Run the timer for work session
        start_time = Time.now
        elapsed_time = run_timer(work_time, :work)
        
        # Handle different timer result cases
        if elapsed_time == :aborted
          puts "❌ Session aborted. No data will be logged."
          print "Do you want to continue with another session? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          next  # Skip to next iteration without logging
        elsif elapsed_time < 0
          print "\nDo you want to continue with the Pomodoro sessions? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          break unless continue
          next  # Skip to next iteration without logging
        end
        
        # Prompt for session update
        puts "\n✏️  Session ##{session_count} complete!"
        print "What did you accomplish in this session? "
        update = gets.chomp
        
        # Log the session
        actual_duration = elapsed_time
        log_session(project, session_count, actual_duration, update)
        completed_count += 1
        
        # Determine break type and time
        break_duration = is_long_break ? long_break_time : break_time
        break_type = is_long_break ? "long break" : "short break"
        
        puts "\n----------------------------------------"
        puts "🕑 Starting #{break_type} (#{format_time(break_duration)})"
        puts "Controls: p = pause/resume, s = skip, a = abort (no log), q = quit"
        puts "----------------------------------------"
        
        # Run the timer for break
        break_result = run_timer(break_duration, :break)
        
        # Handle break result
        if break_result == :skipped
          puts "\n⏩ Break skipped!"
        elsif break_result == :aborted
          puts "❌ Break aborted."
          print "Do you want to continue with another session? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          next  # Skip to next iteration
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
      if completed_count > 0
        puts "🎉 Great work today! You completed #{completed_count} pomodoro sessions."
        puts "Your progress has been logged to: #{log_file}"
      else
        puts "No pomodoro sessions were completed or logged."
      end
      puts "----------------------------------------"
      
      # Clean up status file
      File.write(status_file, "No pomodoro")
    end
  end
  
  def deep_work_session(project)
    # Initialize status file for tmux integration
    status_file = File.join(Dir.home, '.pomodoro_current')
    
    # We've moved the welcome message to the start method to have a consistent flow
    
    set_names = ["First", "Second", "Third"]
    session_names = ["initium", "medius", "fines"]
    session_durations = [60*60, 55*60, 50*60]
    break_durations = [5*60, 10*60]
    
    continue = true
    session_count = 0
    completed_count = 0
    
    set_names.each_with_index do |set_name, set_index|
      break unless continue
      
      puts "\n----------------------------------------"
      puts "🔄 Starting #{set_name} Set"
      puts "----------------------------------------"
      
      # Run through the three sessions in this set
      session_names.each_with_index do |session_name, session_index|
        break unless continue
        session_count += 1
        
        work_duration = session_durations[session_index]
        
        # Start work session
        puts "\n----------------------------------------"
        puts "🧠 Starting #{set_name} Set - #{session_name.capitalize} (#{format_time(work_duration)})"
        puts "Project: #{project}"
        puts "Controls: p = pause/resume, a = abort (no log), q = quit"
        puts "----------------------------------------"
        
        # Update status file
        File.write(status_file, "🧠 #{set_name} - #{session_name}")
        
        # Run the timer for work session
        start_time = Time.now
        elapsed_time = run_timer(work_duration, :work)
        
        # Handle different timer result cases
        if elapsed_time == :aborted
          puts "❌ Session aborted. No data will be logged."
          print "Do you want to continue with the Deep Work sessions? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          next  # Skip to next iteration without logging
        elsif elapsed_time < 0
          print "\nDo you want to continue with the Deep Work sessions? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          break unless continue
          next  # Skip to next iteration without logging
        end
        
        # Prompt for session update
        puts "\n✏️  #{set_name} Set - #{session_name.capitalize} session complete!"
        print "What did you accomplish in this session? "
        update = gets.chomp
        
        # Log the session
        actual_duration = elapsed_time
        log_session(project, session_count, actual_duration, update)
        completed_count += 1
        
        # Skip break after the last session of the last set
        if set_index == set_names.size - 1 && session_index == session_names.size - 1
          break
        end
        
        # Determine break type and time (5 min after initium, 10 min after medius)
        break_index = (session_index == 1) ? 1 : 0
        break_duration = break_durations[break_index]
        
        puts "\n----------------------------------------"
        puts "🕑 Taking a #{break_duration / 60} minute break"
        puts "Controls: p = pause/resume, s = skip, a = abort (no log), q = quit"
        puts "----------------------------------------"
        
        # Run the timer for break
        break_result = run_timer(break_duration, :break)
        
        # Handle break result
        if break_result == :skipped
          puts "\n⏩ Break skipped!"
        elsif break_result == :aborted
          puts "❌ Break aborted."
          print "Do you want to continue with the Deep Work sessions? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          next  # Skip to next iteration
        elsif break_result < 0
          print "\nDo you want to continue with the Deep Work sessions? (y/n): "
          response = gets.chomp.downcase
          continue = (response == 'y' || response == 'yes')
          break unless continue
        else
          puts "\n✅ Break complete!"
        end
      end
      
      # Ask if the user wants to continue to the next set
      if continue && set_index < set_names.size - 1
        print "Continue with the next set? (y/n): "
        response = gets.chomp.downcase
        continue = (response == 'y' || response == 'yes')
      end
    end
    
    puts "\n----------------------------------------"
    if completed_count > 0
      puts "🎉 Congratulations! You completed #{completed_count} deep work sessions."
      puts "Your progress has been logged to: #{log_file}"
    else
      puts "No deep work sessions were completed or logged."
    end
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
    
    # Configure terminal for immediate key detection
    STDIN.echo = false
    STDIN.raw!
    
    begin
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
        if paused
          status_line = "⏸️  #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')} PAUSED | p = resume, q = quit"
        else
          status_line = "⏱️  #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')} remaining | p = pause, a = abort"
          status_line += ", s = skip" if type == :break
          status_line += ", q = quit"
        end
        
        # Update status file for tmux integration
        if paused
          File.write(status_file, "🍅 ⏸️ PAUSED")
        else
          File.write(status_file, "🍅 #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')}")
        end
        
        # Clear line and print status
        print "\r" + " " * 80 # Clear the line with spaces
        print "\r#{status_line}"
        
        # Check for key input (non-blocking)
        if IO.select([STDIN], nil, nil, 0.1)
          key = STDIN.read_nonblock(1) rescue nil
          
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
          when 'a' # Abort (no logging)
            puts "\n❌ Aborting session"
            File.write(status_file, "No pomodoro")
            return :aborted
          when 'q' # Quit
            puts "\n⏹️  Timer stopped."
            File.write(status_file, "No pomodoro")
            return -1 # Return a negative value to indicate quit
          end
        end
        
        # Skip the sleep if paused
        sleep 0.1 unless paused
      end
    ensure
      # Restore terminal settings
      STDIN.echo = true
      STDIN.cooked!
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

# Only run OptionParser when this file is being executed directly (not required in tests)
if __FILE__ == $PROGRAM_NAME
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
    
    opts.on("-d", "--deep-work", "Enable Deep Work mode (3 sets of 3 sessions)") do
      options[:deep_work_mode] = true
    end
    
    opts.on("-h", "--help", "Show help message") do
      puts opts
      exit
    end
  end.parse!

  # Start the Pomodoro timer
  PomodoroTimer.new(options).start
end