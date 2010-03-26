require 'erb'
require 'json'
require 'capistrano/ext/multistage'

set :application, "pbcore"
set :repository,  "git://git.mlcastle.net/pbcore.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

set :keep_releases, 5

# database yml from http://shanesbrain.net/2007/5/30/managing-database-yml-with-capistrano-2-0

namespace :db do
  desc "Create database yaml in shared path"
  task :default do
    db_config = ERB.new <<-EOF
base: &base
  adapter: mysql
  encoding: utf8
  host: #{app_db_host}
  username: #{app_db_user}
  password: #{app_db_pass}

development:
  database: #{application}_dev
  <<: *base

test:
  database: #{application}_test
  <<: *base

production:
  database: #{application}
  <<: *base
EOF

    run "mkdir -p #{shared_path}/config"
    put db_config.result, "#{shared_path}/config/database.yml"
  end

  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Synchronize the remote database to your local system"
  task :sync do
    IO.popen("mysql #{application}_development", "w") do |local_mysql|
      run "mysqldump --opt -h#{app_db_host} -u#{app_db_user} -p #{application}" do |channel, stream, data|
        if data =~ /^Enter password:/
          channel.send_data "#{app_db_pass}\n"
        else
          local_mysql.write data
        end
      end
    end
  end
end

after "deploy:setup", :db
after "deploy:update_code", "db:symlink"

namespace :aws do
  desc "Create AWS YAML File"
  task :default do
    aws_config = ERB.new <<-EOF
<% ["development", "test", "production"].each do |env| %>
<%= env %>:
  bucket_name: #{aws_bucket}
  access_key_id: #{aws_access}
  secret_access_key: #{aws_secret}
  cloudfront_distro: #{cloudfront_distro}
<% end %>
EOF
    put aws_config.result, "#{shared_path}/config/amazon_s3.yml"
  end

  desc "Symlink the AWS YAML"
  task :symlink do
    run "ln -nfs #{shared_path}/config/amazon_s3.yml #{release_path}/config/amazon_s3.yml"
  end
end

after "deploy:setup", :aws
after "deploy:update_code", "aws:symlink"

namespace :exceptional do
  desc "configure exceptional"
  task :config do
    if exists?(:exceptional_key)
      exceptional_config = {"api-key" => exceptional_key}
      put exceptional_config.to_yaml, "#{shared_path}/config/exceptional.yml"
    end
  end

  desc "symlink exceptional config"
  task :symlink do
    if exists?(:exceptional_key)
      run "ln -nfs #{shared_path}/config/exceptional.yml #{release_path}/config/exceptional.yml"
    end
  end
end

after "deploy:setup", "exceptional:config"
after "deploy:update_code", "exceptional:symlink"

namespace :app do
  desc "configure application"
  task :config do
    put app_config.to_json, "#{release_path}/config/application.json"
    if app_config[:auth_ruleset]
      run "cd #{release_path}/config && ln -fs auth_rules/#{app_config[:auth_ruleset]}.rb authorization_rules.rb"
    end
  end
end

after "deploy:update_code", "app:config"

# http://blog.ninjahideout.com/posts/busting-a-cap-in-yo-ass

set :deploy_port, 9000 unless exists?(:deploy_port)
set :cluster_instances, 3 unless exists?(:cluster_instances)

set :shared_config_path, "#{shared_path}/configs"

def public_configuration_location_for(server = :thin)
  "#{current_path}/config/#{server}.yml"
end

def shared_configuration_location_for(server = :thin)
  "#{shared_config_path}/#{server}.yml"
end

def pidfile_location_for(server = :thin)
  "#{shared_path}/pids/#{server}.pid"
end

namespace :configuration do
  desc "Makes link for database"
  task :make_default_folders, :roles => :app do
    run "mkdir -p #{shared_config_path}"
  end

  desc "Symlinks the site_key.txt file"
  task :symlink_site_key, :roles => :app do
    run "ln -nsf #{shared_config_path}/site_key.txt #{release_path}/config/site_key.txt"
  end
end

namespace :thin do
  desc "Generate a thin configuration file"
  task :build_configuration, :roles => :app do
    config_options = {
      "user" => user,
      "group" => user,
      "log" => "#{current_path}/log/thin.log",
      "chdir" => current_path,
      "port" => deploy_port,
      "servers" => cluster_instances.to_i,
      "environment" => "production",
      "address" => "localhost",
      "pid" => pidfile_location_for(:thin)
    }.to_yaml
    put config_options, shared_configuration_location_for(:thin)
  end

  desc "Links the configuration file"
  task :link_configuration_file, :roles => :app do
    run "ln -nsf #{shared_configuration_location_for(:thin)} #{public_configuration_location_for(:thin)}"
  end

  desc "Setup Thin Cluster After Code Update"
  task :link_global_configuration, :roles => :app do
    run "ln -nsf #{shared_configuration_location_for(:thin)} /etc/thin/#{application}.yml"
  end

  %w(start stop restart).each do |action|
    desc "#{action} this app's Thin Cluster"
    task action.to_sym, :roles => :app do
      run "#{rb_bin_path}/thin #{action} -C #{shared_configuration_location_for(:thin)}"
    end
  end
end

namespace :unicorn do
  desc "Generate a unicorn configuration file"
  task :build_configuration, :roles => :app do
    unicorn_config = ERB.new(File.read(File.join("config", "unicorn.cfg.erb")))
    put unicorn_config.result(binding), shared_configuration_location_for(:unicorn)
  end

  desc "Links the configuration file"
  task :link_configuration_file, :roles => :app do
    run "ln -nsf #{shared_configuration_location_for(:unicorn)} #{public_configuration_location_for(:unicorn)}"
  end


  desc "Start unicorn"
  task :start, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/unicorn_rails -c #{shared_configuration_location_for(:unicorn)} -E production -D"
  end

  desc "Gracefully stop unicorn"
  task :stop, :roles => :app do
    run "[ -f #{pidfile_location_for(:unicorn)} ] && kill -QUIT `cat #{pidfile_location_for(:unicorn)}`"
  end

  desc "Restart unicorn"
  task :restart, :roles => :app do
    # gracefully stop
    begin
      run "[ -f #{pidfile_location_for(:unicorn)} ] && kill -USR2 `cat #{pidfile_location_for(:unicorn)}`"
    rescue CommandError => e
      logger.info "restarting failed; trying just to start" if logger
    end

    start
  end
end

namespace :nginx do
  %w(start stop restart reload).each do |action|
    desc "#{action} the Nginx processes on the web server."
    task action.to_sym , :roles => :web do
      sudo "/etc/init.d/nginx #{action}"
    end
  end
end

namespace :deploy do
  %w(start stop restart).each do |action|
    desc "#{action} our server"
    task action.to_sym do
      find_and_execute_task("ourserver:#{action}")
      find_and_execute_task("solr:#{action}")
      find_and_execute_task("delayed_job:#{action}")
    end
  end

  desc "Shrink and bundle js and css"
  task :bundle, :roles => :web, :except => { :no_release => true } do
    run "cd #{release_path}; RAILS_ROOT=#{release_path} rake bundle:all"
  end
end

namespace :ourserver do
  %w(start stop restart build_configuration link_configuration_file).each do |action|
    task action.to_sym do
      find_and_execute_task("#{server_type}:#{action}")
    end
  end
end

after "deploy:setup", "configuration:make_default_folders"
after "deploy:setup", "ourserver:build_configuration"

after "deploy:symlink", "ourserver:link_configuration_file"
after "deploy:update_code", "configuration:symlink_site_key"
after "deploy:update_code", "deploy:bundle"

namespace :solr do

  desc "Set up solr dir"
  task :setup do
    run "mkdir -p #{shared_path}/solr"
  end

  desc "Re-establish symlinks"
  task :symlink do
    run "ln -nfs #{shared_path}/solr #{current_path}/solr"
  end

  desc "Stop the solr server"
  task :stop, :roles => :app do
    run "cd #{current_path} && PATH=\"#{rb_bin_path}:$PATH\" #{rb_bin_path}/rake RAILS_ENV=production sunspot:solr:stop"
  end

  desc "Start the solr server"
  task :start, :roles => :app do
    run "cd #{current_path} && PATH=\"#{rb_bin_path}:$PATH\" #{rb_bin_path}/rake RAILS_ENV=production sunspot:solr:start"
  end

  desc "Restart the solr server"
  task :restart, :roles => :app do
    find_and_execute_task("solr:stop")
    find_and_execute_task("solr:start")
  end

  desc "Re-index"
  task :index, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/ruby ./script/runner -e production 'Asset.reindex(:include => Asset::ALL_INCLUDES)'"
  end
end

after "deploy:setup", "solr:setup"
after "deploy:symlink", "solr:symlink"

namespace :delayed_job do
  [:start, :stop, :restart].each do |action|
    desc "#{action} dj worker"
    task action do
      run "cd #{current_path} && env RAILS_ENV=production #{rb_bin_path}/ruby ./script/delayed_job #{action}"
    end
  end
end

# http://github.com/javan/whenever/tree/master

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    god_str = exists?(:have_god) ? "-s have_god=1" : ''
    run "cd #{release_path} && PATH=\"#{rb_bin_path}:$PATH\" /usr/bin/env whenever -s server_type=#{server_type} #{god_str} --update-crontab #{application}"
  end
end
