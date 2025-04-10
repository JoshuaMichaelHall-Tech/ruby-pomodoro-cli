# frozen_string_literal: true
# 
# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall
# 
# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

require 'spec_helper'
require 'log-analyzer'
require 'fileutils'
require 'csv'
require 'date'

RSpec.describe PomodoroLogAnalyzer do
  let(:test_log_dir) { File.join(Dir.home, '.pomodoro_test_logs') }
  let(:test_output_file) { 'test_pomodoro_summary.csv' }
  let(:test_public_output) { 'test_pomodoro_public_stats.md' }
  
  before(:each) do
    # Clean up any existing test files
    FileUtils.rm_f(test_output_file) if File.exist?(test_output_file)
    FileUtils.rm_f(test_public_output) if File.exist?(test_public_output)
    
    # Create test log directory if it doesn't exist
    FileUtils.mkdir_p(test_log_dir) unless Dir.exist?(test_log_dir)
    
    # Create sample log files for testing
    create_sample_log_files
    
    # Redirect standard output
    @original_stdout = $stdout
    $stdout = StringIO.new
  end
  
  after(:each) do
    # Restore standard output
    $stdout = @original_stdout
    
    # Clean up test files
    FileUtils.rm_f(test_output_file) if File.exist?(test_output_file)
    FileUtils.rm_f(test_public_output) if File.exist?(test_public_output)
    
    # Clean up sample log files
    FileUtils.rm_rf(Dir.glob(File.join(test_log_dir, '*.csv')))
  end
  
  def create_sample_log_files
    # Create sample log files with realistic data
    dates = [
      Date.today,
      Date.today - 1,
      Date.today - 2
    ]
    
    dates.each do |date|
      log_file = File.join(test_log_dir, "#{date.strftime('%Y-%m-%d')}.csv")
      
      CSV.open(log_file, 'w') do |csv|
        csv << ['date', 'project', 'session', 'duration', 'update']
        
        # Add 3 sessions for each day
        3.times do |i|
          session_number = i + 1
          duration = 1500 + (i * 100) # Varying durations
          update = "Completed task #{session_number} for day #{date.strftime('%Y-%m-%d')}"
          
          csv << [
            date.strftime('%Y-%m-%d'),
            'Test Project',
            session_number,
            duration,
            update
          ]
        end
      end
    end
  end
  
  describe '#initialize' do
    it 'creates a new PomodoroLogAnalyzer with default values' do
      analyzer = PomodoroLogAnalyzer.new
      
      expect(analyzer.log_dir).to eq(File.join(Dir.home, '.pomodoro_logs'))
      expect(analyzer.output_file).to eq('pomodoro_summary.csv')
    end
    
    it 'creates a new PomodoroLogAnalyzer with custom values' do
      options = {
        log_dir: test_log_dir,
        output_file: test_output_file,
        start_date: '2025-01-01',
        end_date: '2025-12-31'
      }
      
      analyzer = PomodoroLogAnalyzer.new(options)
      
      expect(analyzer.log_dir).to eq(test_log_dir)
      expect(analyzer.output_file).to eq(test_output_file)
    end
  end
  
  describe '#analyze' do
    it 'processes log files and generates a summary' do
      analyzer = PomodoroLogAnalyzer.new(
        log_dir: test_log_dir,
        output_file: test_output_file
      )
      
      analyzer.analyze
      
      # Check that the output file was created
      expect(File.exist?(test_output_file)).to be true
      
      # Read the summary file and check its contents
      csv_data = CSV.read(test_output_file, headers: true)
      
      # Should have 3 days of data
      expect(csv_data.size).to eq(3)
      
      # Check structure of the summary
      expect(csv_data.headers).to eq(['Date', 'Project', 'Sessions', 'Total Time (mins)', 'Avg Session (mins)', 'Updates'])
      
      # Check data for consistency
      csv_data.each do |row|
        expect(row['Project']).to eq('Test Project')
        expect(row['Sessions'].to_i).to eq(3)
        expect(row['Total Time (mins)'].to_f).to be > 0
        expect(row['Avg Session (mins)'].to_f).to be > 0
        expect(row['Updates']).to include('Completed task')
      end
    end
    
    it 'handles empty log directory' do
      # Clear the test log directory
      FileUtils.rm_rf(Dir.glob(File.join(test_log_dir, '*.csv')))
      
      analyzer = PomodoroLogAnalyzer.new(
        log_dir: test_log_dir,
        output_file: test_output_file
      )
      
      analyzer.analyze
      
      # Check output
      output = $stdout.string
      expect(output).to include('No log files found')
    end
    
    it 'handles date filtering' do
      # Set specific date range
      start_date = (Date.today - 1).strftime('%Y-%m-%d')
      end_date = Date.today.strftime('%Y-%m-%d')
      
      analyzer = PomodoroLogAnalyzer.new(
        log_dir: test_log_dir,
        output_file: test_output_file,
        start_date: start_date,
        end_date: end_date
      )
      
      analyzer.analyze
      
      # Read the summary file and check its contents
      csv_data = CSV.read(test_output_file, headers: true)
      
      # Should have only 2 days of data (today and yesterday)
      expect(csv_data.size).to eq(2)
      
      # Check that all dates are within the specified range
      csv_data.each do |row|
        date = Date.parse(row['Date'])
        expect(date).to be >= Date.parse(start_date)
        expect(date).to be <= Date.parse(end_date)
      end
    end
  end
  
  describe '#generate_public_summary' do
    it 'creates a public summary without personal details' do
      options = {
        log_dir: test_log_dir,
        public_output: test_public_output
      }
      
      analyzer = PomodoroLogAnalyzer.new(options)
      analyzer.generate_public_summary(options)
      
      # Check that the public summary file was created
      expect(File.exist?(test_public_output)).to be true
      
      # Read the public summary and check its contents
      content = File.read(test_public_output)
      
      # Check structure and content
      expect(content).to include('# Pomodoro Challenge Stats')
      expect(content).to include('## Summary')
      expect(content).to include('Total Days')
      expect(content).to include('Total Sessions')
      expect(content).to include('Total Focus Time')
      
      # Check that it doesn't contain personal details
      expect(content).not_to include('Completed task')
      expect(content).not_to include('Test Project')
      
      # Check that it includes the ASCII chart
      expect(content).to include('Last 14 days of activity:')
    end
  end
  
  describe 'private methods' do
    let(:analyzer) { PomodoroLogAnalyzer.new(log_dir: test_log_dir) }
    
    describe '#calculate_streak' do
      it 'calculates the correct streak with today included' do
        dates = [
          (Date.today - 2).strftime('%Y-%m-%d'),
          (Date.today - 1).strftime('%Y-%m-%d'),
          Date.today.strftime('%Y-%m-%d')
        ]
        
        streak = analyzer.send(:calculate_streak, dates)
        expect(streak).to eq(3)
      end
      
      it 'calculates the correct streak with yesterday as the last day' do
        dates = [
          (Date.today - 3).strftime('%Y-%m-%d'),
          (Date.today - 2).strftime('%Y-%m-%d'),
          (Date.today - 1).strftime('%Y-%m-%d')
        ]
        
        streak = analyzer.send(:calculate_streak, dates)
        expect(streak).to eq(3)
      end
      
      it 'returns 0 for old dates' do
        dates = [
          (Date.today - 10).strftime('%Y-%m-%d'),
          (Date.today - 9).strftime('%Y-%m-%d'),
          (Date.today - 8).strftime('%Y-%m-%d')
        ]
        
        streak = analyzer.send(:calculate_streak, dates)
        expect(streak).to eq(0)
      end
      
      it 'handles empty dates array' do
        streak = analyzer.send(:calculate_streak, [])
        expect(streak).to eq(0)
      end
    end
    
    describe '#calculate_weekly_average' do
      it 'calculates weekly average from daily sessions' do
        daily_sessions = {
          (Date.today - 6).strftime('%Y-%m-%d') => 3,
          (Date.today - 5).strftime('%Y-%m-%d') => 4,
          (Date.today - 4).strftime('%Y-%m-%d') => 2,
          (Date.today - 3).strftime('%Y-%m-%d') => 5,
          (Date.today - 2).strftime('%Y-%m-%d') => 3,
          (Date.today - 1).strftime('%Y-%m-%d') => 4,
          Date.today.strftime('%Y-%m-%d') => 3
        }
        
        average = analyzer.send(:calculate_weekly_average, daily_sessions)
        expect(average).to eq(24.0) # All in same week, so 24/1 = 24.0
      end
      
      it 'handles multiple weeks' do
        daily_sessions = {
          (Date.today - 13).strftime('%Y-%m-%d') => 2,
          (Date.today - 12).strftime('%Y-%m-%d') => 3,
          (Date.today - 6).strftime('%Y-%m-%d') => 4,
          (Date.today - 5).strftime('%Y-%m-%d') => 5,
          Date.today.strftime('%Y-%m-%d') => 6
        }
        
        # This will depend on when the weeks break, so we can't predict exact value
        # Just check it's a reasonable number
        average = analyzer.send(:calculate_weekly_average, daily_sessions)
        expect(average).to be_a(Float)
        expect(average).to be > 0
      end
      
      it 'handles empty hash' do
        average = analyzer.send(:calculate_weekly_average, {})
        expect(average).to eq(0)
      end
    end
  end
end