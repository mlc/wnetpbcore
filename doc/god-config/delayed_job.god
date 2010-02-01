God.watch do |w|
  w.uid = 'pbcore'
  w.gid = 'pbcore'
  w.group = 'pbcore'
  w.name = 'delayed_job'
  w.interval = 30.seconds

  w.env = { "PATH" => "/opt/ruby-enterprise-1.8.7-20090928/bin:#{ENV["PATH"]}", "RAILS_ENV" => "production" }
  w.start = "/opt/ruby-enterprise-1.8.7-20090928/bin/ruby /var/www/pbcore/current/script/delayed_job start -- production"
  w.stop = "/opt/ruby-enterprise-1.8.7-20090928/bin/ruby /var/www/pbcore/current/script/delayed_job stop -- production"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.pid_file = "/var/www/pbcore/current/tmp/pids/delayed_job.pid"
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval  = 5.seconds
      c.running   = false
    end
  end
end
