# frozen_string_literal: true
# 
# Ruby Pomodoro CLI - A terminal-based Pomodoro timer with analytics
# Copyright (c) 2025 Joshua Michael Hall
# 
# This program is released under the MIT license.
# See the LICENSE.md file for the full license text.

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation'
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

desc 'Run tests with coverage analysis'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Run the test suite and style checks'
task check: [:spec, :rubocop]

desc 'Make the executable scripts executable'
task :chmod do
  system 'chmod +x bin/pomodoro'
  system 'chmod +x bin/pomodoro_analyze'
  system 'chmod +x install.sh'
  system 'chmod +x uninstall.sh'
  system 'chmod +x update.sh'
end

desc 'Create setup symlinks for local development'
task :devsetup do
  require 'fileutils'
  
  home_dir = ENV['HOME']
  local_bin = File.join(home_dir, '.local', 'bin')
  local_lib = File.join(home_dir, '.local', 'lib')
  
  FileUtils.mkdir_p(local_bin)
  FileUtils.mkdir_p(local_lib)
  
  # Create symlinks
  FileUtils.ln_sf(File.expand_path('bin/pomodoro'), File.join(local_bin, 'pomodoro'))
  FileUtils.ln_sf(File.expand_path('bin/pomodoro_analyze'), File.join(local_bin, 'pomodoro_analyze'))
  FileUtils.ln_sf(File.expand_path('lib/pomodoro-timer.rb'), File.join(local_lib, 'pomodoro-timer.rb'))
  FileUtils.ln_sf(File.expand_path('lib/log-analyzer.rb'), File.join(local_lib, 'log-analyzer.rb'))
  
  puts 'Development setup complete!'
  puts "Make sure #{local_bin} is in your PATH"
end

task default: :spec