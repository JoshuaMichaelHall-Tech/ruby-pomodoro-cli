#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall

# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

require 'csv'
require 'date'
require 'fileutils'
require 'optparse'

class PomodoroLogAnalyzer
  attr_reader :log_dir, :output_file

  def initialize(options = {})
    @log_dir = options[:log_dir] || File.join(Dir.home, '.pomodoro_logs')
    @output_file = options[:output_file] || 'pomodoro_summary.csv'
    @start_date = options[:start_date]
    @end_date = options[:end_date] || Date.today.strftime('%Y-%m-%d')
  end

  def analyze
    puts "Analyzing pomodoro logs from #{log_dir}..."
    
    # Get all log files
    log_files = Dir.glob(File.join(log_dir, '*.csv')).sort
    
    # Filter by date if specified
    if @start_date
      log_files.select! do |file|
        date_str = File.basename(file, '.csv')
        date_str >= @start_date && date_str <= @end_date
      end
    end
    
    if log_files.empty?
      puts "No log files found for the specified date range."
      return
    end
    
    # Prepare the daily summary data
    daily_summaries = []
    
    log_files.each do |log_file|
      date = File.basename(log_file, '.csv')
      
      # Skip if not a valid date format
      next unless date =~ /^\d{4}-\d{2}-\d{2}$/
      
      begin
        sessions = CSV.read(log_file, headers: true)
        
        # Skip if no sessions
        next if sessions.empty?
        
        project = sessions.first['project']
        session_count = sessions.size
        total_duration = sessions.sum { |s| s['duration'].to_i }
        avg_duration = session_count > 0 ? (total_duration / session_count / 60.0).round(1) : 0
        
        # Combine all updates for the day
        updates = sessions.map.with_index(1) do |s, i|
          "Session #{i}: #{s['update']}"
        end.join(' | ')
        
        daily_summaries << {
          date: date,
          project: project,
          sessions: session_count,
          total_time_mins: (total_duration / 60.0).round(1),
          avg_session_mins: avg_duration,
          updates: updates
        }
      rescue StandardError => e
        puts "Error processing #{log_file}: #{e.message}"
      end
    end
    
    # Write summary to output file
    CSV.open(output_file, 'w') do |csv|
      csv << ['Date', 'Project', 'Sessions', 'Total Time (mins)', 'Avg Session (mins)', 'Updates']
      
      daily_summaries.each do |summary|
        csv << [
          summary[:date],
          summary[:project],
          summary[:sessions],
          summary[:total_time_mins],
          summary[:avg_session_mins],
          summary[:updates]
        ]
      end
    end
    
    puts "Analysis complete! Summary written to #{output_file}"
    puts "Summary of analyzed data:"
    puts "------------------------"
    puts "Total days: #{daily_summaries.size}"
    puts "Total sessions: #{daily_summaries.sum { |s| s[:sessions] }}"
    puts "Total time: #{daily_summaries.sum { |s| s[:total_time_mins] }} minutes"
    
    if daily_summaries.any?
      avg_sessions_per_day = (daily_summaries.sum { |s| s[:sessions] } / daily_summaries.size.to_f).round(1)
      puts "Average sessions per day: #{avg_sessions_per_day}"
    end
  end

  def generate_public_summary(options = {})
    puts "Generating public summary without personal details..."
    
    # Get all log files
    log_files = Dir.glob(File.join(log_dir, '*.csv')).sort
    
    # Filter by date if specified
    if @start_date
      log_files.select! do |file|
        date_str = File.basename(file, '.csv')
        date_str >= @start_date && date_str <= @end_date
      end
    end
    
    if log_files.empty?
      puts "No log files found for the specified date range."
      return
    end
    
    # Prepare the summary data
    total_days = log_files.size
    total_sessions = 0
    total_time_mins = 0
    dates = []
    daily_sessions = {}
    
    log_files.each do |log_file|
      date = File.basename(log_file, '.csv')
      
      # Skip if not a valid date format
      next unless date =~ /^\d{4}-\d{2}-\d{2}$/
      
      begin
        sessions = CSV.read(log_file, headers: true)
        
        # Skip if no sessions
        next if sessions.empty?
        
        dates << date
        session_count = sessions.size
        total_sessions += session_count
        daily_sessions[date] = session_count
        
        duration = sessions.sum { |s| s['duration'].to_i }
        total_time_mins += (duration / 60.0).round(1)
      rescue StandardError => e
        puts "Error processing #{log_file}: #{e.message}"
      end
    end
    
    # Calculate streaks
    dates.sort!
    current_streak = calculate_streak(dates)
    
    # Calculate weekly averages
    weekly_avg = calculate_weekly_average(daily_sessions)
    
    # Output file name
    output_file = options[:public_output] || 'pomodoro_public_stats.md'
    
    # Write the public summary
    File.open(output_file, 'w') do |file|
      file.puts "# Pomodoro Challenge Stats"
      file.puts
      file.puts "## Summary"
      file.puts "- **Total Days**: #{total_days}"
      file.puts "- **Total Sessions**: #{total_sessions}"
      file.puts "- **Total Focus Time**: #{total_time_mins.round} minutes (#{(total_time_mins / 60.0).round(1)} hours)"
      file.puts "- **Current Streak**: #{current_streak} days"
      file.puts "- **Weekly Average**: #{weekly_avg} sessions"
      file.puts "- **Last Updated**: #{Date.today.strftime('%Y-%m-%d')}"
      file.puts
      file.puts "## Recent Activity"
      
      # Add a simple ASCII chart for the last 2 weeks
      recent_dates = dates.sort.last(14)
      file.puts "```"
      file.puts "Last 14 days of activity:"
      recent_dates.each do |date|
        count = daily_sessions[date] || 0
        bar = "█" * count
        file.puts "#{date}: #{bar} (#{count})"
      end
      file.puts "```"
    end
    
    puts "Public summary written to #{output_file}"
    puts "You can safely share this file without revealing task details."
  end

  private

  def calculate_streak(dates)
    return 0 if dates.empty?
    
    # Convert to Date objects for easier comparison
    date_objects = dates.map { |d| Date.parse(d) }
    date_objects.sort!
    
    # Check if today is in the dates
    today = Date.today
    last_date = date_objects.last
    
    # If the last date is not today or yesterday, streak is 0
    return 0 if (today - last_date).to_i > 1
    
    # Count the streak
    streak = 1
    current_date = last_date
    
    while date_objects.include?(current_date - 1)
      streak += 1
      current_date -= 1
    end
    
    streak
  end

  def calculate_weekly_average(daily_sessions)
    return 0 if daily_sessions.empty?
    
    # Group by week
    weeks = {}
    daily_sessions.each do |date_str, count|
      date = Date.parse(date_str)
      week = date.strftime('%Y-%U') # Year and week number
      weeks[week] ||= 0
      weeks[week] += count
    end
    
    # Calculate average
    (weeks.values.sum / weeks.size.to_f).round(1)
  end
end

# Only run OptionParser when this file is being executed directly (not required in tests)
if __FILE__ == $PROGRAM_NAME
  # Parse command-line options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: pomodoro_analyze [options]"
    
    opts.on("-d", "--directory DIR", "Log directory (default: ~/.pomodoro_logs)") do |d|
      options[:log_dir] = d
    end
    
    opts.on("-o", "--output FILE", "Output file (default: pomodoro_summary.csv)") do |o|
      options[:output_file] = o
    end
    
    opts.on("-s", "--start-date DATE", "Start date in YYYY-MM-DD format") do |s|
      options[:start_date] = s
    end
    
    opts.on("-e", "--end-date DATE", "End date in YYYY-MM-DD format (default: today)") do |e|
      options[:end_date] = e
    end
    
    opts.on("--public-summary", "Generate a public summary without personal details") do
      options[:public_summary] = true
    end
    
    opts.on("--public-output FILE", "Public summary output file (default: pomodoro_public_stats.md)") do |p|
      options[:public_output] = p
    end
    
    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit
    end
  end.parse!

  # Run the analyzer
  analyzer = PomodoroLogAnalyzer.new(options)
  if options[:public_summary]
    analyzer.generate_public_summary(options)
  else
    analyzer.analyze
  end
end
