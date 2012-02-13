# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if !File.exists?(File.join(Rails.root, 'config','authorization_rules.rb'))
  raise "Error: config/authorization_rules.rb must be present. Pick one from config/auth_rules."
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.

  config.gem 'haml', :version => '~> 3.0.6'	
  config.gem 'libxml-ruby', :lib => 'libxml' #, :version => '0.8.0'
  config.gem 'libxslt-ruby', :lib => 'libxslt' #, :version => '0.9.2'
  config.gem 'rubyzip', :lib => 'zip/zip'
  config.gem 'mime-types', :lib => 'mime/types'
  config.gem 'uuidtools', :version => '1.0.4'
  config.gem 'mislav-will_paginate', :version => '~> 2.2.3', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'whenever', :version => "0.4.1", :lib => false
  config.gem 'rsolr', :version => '0.9.6' # NEWER VERSIONS ARE BUGGY!
  config.gem 'sunspot', :version => "1.1.0", :lib => 'sunspot'
  config.gem 'sunspot_rails', :version => "1.1.0", :lib => 'sunspot/rails'
  config.gem 'grit'
  config.gem 'aws-s3', :lib => 'aws/s3'
  config.gem 'delayed_job', :lib => 'delayed_job', :version => "<2"
  config.gem 'exceptional' if RAILS_ENV=='production'
  config.gem 'fastercsv'
  config.gem 'formtastic', :version => "1.2.4"
  config.gem 'newrelic_rpm'
  config.gem 'carrierwave', :version => '0.4.10'

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end
