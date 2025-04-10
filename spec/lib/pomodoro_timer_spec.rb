# frozen_string_literal: true
# 
# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall
# 
# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

require 'spec_helper'
require 'pomodoro-timer'
require 'fileutils'
require 'csv'

RSpec.describe PomodoroTimer do
  let(:test_log_dir) { File.join(Dir.home, '.pomodoro_test_logs') }
  let(:test_options) do
    { 
      work_time: 5, # 5 seconds for testing
      break_time: 2, # 2 seconds for testing
      long_break_time: 3, # 3 seconds for testing
      sessions_before_long_break: 2
    }
  end
  
  # Mock the IO class to simulate user input
  before(:each) do
    # Stub the gets method to return predetermined values
    allow_any_instance_of(Kernel).to receive(:gets).and_return("Test Project\n", "y\n", "Added a test feature\n", "y\n")
  
    # Stub the getch method to simulate key presses
    allow(STDIN).to receive(:getch).and_return('q')
  
    # Redirect standard output
    @original_stdout = $stdout
    $stdout = StringIO.new
  
    # Create test log directory if it doesn't exist
    FileUtils.mkdir_p(test_log_dir)
  
    # Instead of stubbing initialize, patch the class before each test
    stub_const("PomodoroTimer::DEFAULT_LOG_DIR", test_log_dir)
  end

  after(:each) do
    # Restore standard output
    $stdout = @original_stdout
    
    # Clean up any test files
    FileUtils.rm_rf(Dir.glob(File.join(test_log_dir, '*.csv')))
  end
  
  describe '#initialize' do
    it 'creates a new PomodoroTimer with default values' do
      timer = PomodoroTimer.new
      
      expect(timer.work_time).to eq(PomodoroTimer::DEFAULT_WORK_TIME)
      expect(timer.break_time).to eq(PomodoroTimer::DEFAULT_BREAK_TIME)
      expect(timer.long_break_time).to eq(PomodoroTimer::DEFAULT_LONG_BREAK_TIME)
      expect(timer.sessions_before_long_break).to eq(PomodoroTimer::DEFAULT_SESSIONS_BEFORE_LONG_BREAK)
      expect(timer.deep_work_mode).to eq(PomodoroTimer::DEFAULT_DEEP_WORK_MODE)
    end
    
    it 'creates a new PomodoroTimer with custom values' do
      timer = PomodoroTimer.new(test_options)
      
      expect(timer.work_time).to eq(test_options[:work_time])
      expect(timer.break_time).to eq(test_options[:break_time])
      expect(timer.long_break_time).to eq(test_options[:long_break_time])
      expect(timer.sessions_before_long_break).to eq(test_options[:sessions_before_long_break])
    end
    
    it 'creates a log file if it does not exist' do
      log_file = File.join(test_log_dir, "#{Date.today.strftime('%Y-%m-%d')}.csv")
      FileUtils.rm_f(log_file) if File.exist?(log_file)
      
      timer = PomodoroTimer.new(test_options)
      
      expect(File.exist?(timer.log_file)).to be true
      
      # Check headers
      headers = CSV.read(timer.log_file).first
      expect(headers).to eq(['date', 'project', 'session', 'duration', 'update'])
    end
  end
  
  describe '#run_timer' do
    it 'returns early when quit key is pressed' do
      timer = PomodoroTimer.new(test_options)
      
      # Ensure IO.select returns immediately for key input simulation
      allow(IO).to receive(:select).and_return([STDIN])
      
      result = timer.send(:run_timer, 10)
      
      expect(result).to eq(-1) # Negative value indicates quit
    end
  end
  
  describe '#log_session' do
    it 'logs a session to the CSV file' do
      timer = PomodoroTimer.new(test_options)
      project = 'Test Project'
      session_number = 1
      duration = 1500 # 25 minutes in seconds
      update = 'Completed test task'
      
      timer.send(:log_session, project, session_number, duration, update)
      
      # Read the log file and check if the session was logged
      csv_data = CSV.read(timer.log_file)
      expect(csv_data.size).to eq(2) # Headers + 1 session
      
      session_data = csv_data[1]
      expect(session_data[1]).to eq(project)
      expect(session_data[2].to_i).to eq(session_number)
      expect(session_data[3].to_i).to eq(duration)
      expect(session_data[4]).to eq(update)
    end
  end
  
  describe '#format_time' do
    it 'formats seconds into minutes:seconds format' do
      timer = PomodoroTimer.new
      
      expect(timer.send(:format_time, 65)).to eq('1:05')
      expect(timer.send(:format_time, 3600)).to eq('60:00')
      expect(timer.send(:format_time, 1500)).to eq('25:00')
      expect(timer.send(:format_time, 45)).to eq('0:45')
    end
  end
  
  # Integration test with controlled environment
  describe 'integration' do
    it 'handles a simplified session flow' do
      # Override run_timer to avoid actual waiting
      allow_any_instance_of(PomodoroTimer).to receive(:run_timer).and_return(5)
      
      timer = PomodoroTimer.new(test_options)
      
      # Since we're mocking gets, we need a way to exit the loop
      # This will simulate a user running one pomodoro and then quitting
      allow_any_instance_of(Kernel).to receive(:gets).and_return(
        "Test Project\n", # Project name
        "Added a test feature\n", # Session update
        "n\n" # Do not continue
      )
      
      # Run the timer
      expect { timer.start }.not_to raise_error
      
      # Check that a session was logged
      csv_data = CSV.read(timer.log_file)
      expect(csv_data.size).to eq(2) # Headers + 1 session
      
      session_data = csv_data[1]
      expect(session_data[1]).to eq('Test Project')
      expect(session_data[4]).to eq('Added a test feature')
    end
  end
end
