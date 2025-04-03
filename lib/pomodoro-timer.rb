  def run_timer(duration)
    end_time = Time.now + duration
    status_file = File.join(Dir.home, '.pomodoro_current')
    
    while Time.now < end_time
      remaining = (end_time - Time.now).to_i
      mins, secs = remaining.divmod(60)
      
      # Update status file for tmux integration
      File.write(status_file, "🍅 #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')}")
      
      # Clear line and print remaining time
      print "\r⏱️  #{mins.to_s.rjust(2, '0')}:#{secs.to_s.rjust(2, '0')} remaining"
      
      # Add a way to pause or stop the timer
      if STDIN.ready?
        key = STDIN.getch
        if key == 'q'
          puts "\nTimer stopped."
          File.write(status_file, "No pomodoro")
          break
        end
      end
      
      sleep 1
    end
    
    # Reset status file
    File.write(status_file, "No pomodoro")
    
    # Play a sound to notify the user when the time is up
    puts "\n\a" # Terminal bell
  end