require 'erb'
require 'capistrano/ext/multistage'

set :application, "pbcore"
set :repository,  "git://git.mlcastle.net/pbcore.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

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
    run "ln -nsf #{shared_config_path}/site_key.txt #{current_path}/config/site_key.txt"
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
      find_and_execute_task("sphinx:#{action}")
      find_and_execute_task("backgroundrb:#{action}")
    end
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
after "deploy:symlink", "configuration:symlink_site_key"

# http://www.updrift.com/article/deploying-a-rails-app-with-thinking-sphinx
namespace :sphinx do

  desc "Set up db/sphinx dir"
  task :setup do
    run "mkdir -p #{shared_path}/db/sphinx"
  end

  desc "Re-establish symlinks"
  task :symlink do
    run "ln -nfs #{shared_path}/db/sphinx #{current_path}/db/sphinx"
  end

  desc "Stop the sphinx server"
  task :stop, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/rake RAILS_ENV=production thinking_sphinx:stop"
  end

  desc "Start the sphinx server"
  task :start, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/rake RAILS_ENV=production thinking_sphinx:configure && #{rb_bin_path}/rake RAILS_ENV=production thinking_sphinx:start"
  end

  desc "Restart the sphinx server"
  task :restart, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/rake RAILS_ENV=production thinking_sphinx:configure && #{rb_bin_path}/rake RAILS_ENV=production thinking_sphinx:running_start"

  end

  desc "Ask sphinx to re-index"
  task :index, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/rake RAILS_ENV=production thinking_sphinx:index"
  end
end

after "deploy:setup", "sphinx:setup"
after "deploy:symlink", "sphinx:symlink"

# http://www.brynary.com/2007/4/8/capistrano-tasks-for-backgroundrb
# but some pretty heavy modifications

namespace :backgroundrb do
  desc "Stop the backgroundrb server"
  task :stop, :roles => :app do
    run "cd #{current_path} && #{rb_bin_path}/ruby ./script/backgroundrb stop -e production"
  end

  desc "Start the backgroundrb server"
  task :start, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production nohup #{rb_bin_path}/ruby ./script/backgroundrb start -e production > /dev/null 2>&1"
  end

  desc "Start the backgroundrb server"
  task :restart, :roles => :app do
    stop
    start
  end
end

# http://github.com/javan/whenever/tree/master

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && #{rb_bin_path}/whenever --update-crontab #{application}"
  end
end
