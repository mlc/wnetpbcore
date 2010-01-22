rails_env = ENV['RAILS_ENV'] || 'production'
rails_root = ENV['RAILS_ROOT'] || "/var/www/pbcore/current"

God.watch do |w|
  w.uid = 'pbcore'
  w.gid = 'pbcore'
  w.group = 'pbcore'
  w.name = 'solr'
  w.interval = 30.seconds

  w.env = { "PATH" => "/opt/ruby-enterprise-1.8.7-20090928/bin:#{ENV["PATH"]}", "RAILS_ENV" => rails_env }
  w.start = "cd #{rails_root} && /opt/ruby-enterprise-1.8.7-20090928/bin/rake sunspot:solr:start"
  w.stop = "cd #{rails_root} && /opt/ruby-enterprise-1.8.7-20090928/bin/rake sunspot:solr:stop"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.pid_file = "#{rails_root}/solr/pids/#{rails_env}/sunspot-solr.pid"
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval  = 5.seconds
      c.running   = false
    end
  end
end
