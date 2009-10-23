God.watch do |w|
  w.uid = 'www'
  w.gid = 'www'
  w.name = 'pbcore-backgroundrb'
  w.interval = 30.seconds

  w.env = { "PATH" => "/opt/ruby-enterprise-1.8.7-20090928/bin:#{ENV["PATH"]}" }
  w.start = "/opt/ruby-enterprise-1.8.7-20090928/bin/ruby /var/www/pbcore/current/script/backgroundrb start -e production"
  w.stop = "/opt/ruby-enterprise-1.8.7-20090928/bin/ruby /var/www/pbcore/current/script/backgroundrb stop -e production"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.pid_file = "/var/www/pbcore/current/tmp/pids/backgroundrb_11006.pid"
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval  = 5.seconds
      c.running   = false
    end
  end
end
