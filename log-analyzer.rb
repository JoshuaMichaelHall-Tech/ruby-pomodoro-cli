#!/usr/bin/env ruby
# frozen_string_literal: true

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
end

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
  
  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!

# Run the analyzer
PomodoroLogAnalyzer.new(options).analyze
