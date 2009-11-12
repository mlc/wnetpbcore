# http://github.com/blog/519-unicorn-god

# http://unicorn.bogomips.org/SIGNALS.html
 
rails_env = ENV['RAILS_ENV'] || 'production'
rails_root = ENV['RAILS_ROOT'] || "/var/www/pbcore/current"
 
God.watch do |w|
  w.name = "unicorn"
  w.interval = 30.seconds # default
  w.env = { "PATH" => "/opt/ruby-enterprise-1.8.7-20090928/bin:#{ENV["PATH"]}" }
 
  # unicorn needs to be run from the rails root
  w.start = "cd #{rails_root} && /opt/ruby-enterprise-1.8.7-20090928/bin/unicorn_rails -c #{rails_root}/config/unicorn.yml -E #{rails_env} -D"
 
  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{rails_root}/tmp/pids/unicorn.pid`"
 
  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{rails_root}/tmp/pids/unicorn.pid`"
 
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "#{rails_root}/tmp/pids/unicorn.pid"
 
  w.uid = 'www'
  w.gid = 'www'
 
  w.behavior(:clean_pid_file)
 
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
 
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
 
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
 
  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

unicorn_worker_memory_limit = 100_000

Thread.new do
  loop do
    begin
      # unicorn workers
      #
      # ps output line format:
      # 31580 275444 unicorn_rails worker[15] -c /data/github/current/config/unicorn.rb -E production -D
      # pid ram command
 
      lines = `ps -e -www -o pid,rss,command | grep '[u]nicorn_rails worker'`.split("\n")
      lines.each do |line|
        parts = line.split(' ')
        if parts[1].to_i > unicorn_worker_memory_limit
          # tell the worker to die after it finishes serving its request
          ::Process.kill('QUIT', parts[0].to_i)
        end
      end
    rescue Object
      # don't die ever once we've tested this
      nil
    end
 
    sleep 30
  end
end
