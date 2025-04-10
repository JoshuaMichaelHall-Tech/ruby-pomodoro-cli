# frozen_string_literal: true
# 
# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall
# 
# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

require 'fileutils'
require 'timeout'

# Add the lib directory to the load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
    
    # Define groups for the coverage report
    add_group 'Timer', 'lib/pomodoro-timer'
    add_group 'Analyzer', 'lib/log-analyzer'
  end
  
  # Output message to the console
  puts "Running tests with coverage analysis..."
end

# Create a temp directory for test logs
def setup_test_environment
  test_log_dir = File.join(Dir.home, '.pomodoro_test_logs')
  FileUtils.mkdir_p(test_log_dir)
  test_log_dir
end

# Clean up test logs after tests
def cleanup_test_environment
  test_log_dir = File.join(Dir.home, '.pomodoro_test_logs')
  FileUtils.rm_rf(test_log_dir) if Dir.exist?(test_log_dir)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Setup and cleanup for tests
  config.before(:suite) do
    setup_test_environment
  end

  config.after(:suite) do
    cleanup_test_environment
  end
end