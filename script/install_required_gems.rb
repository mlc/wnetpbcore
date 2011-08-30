#!/usr/bin/ruby

# Install pre-requisites for pbcore app.
# Note that `rake gems:install` wont run without these.
# Bundler would handle this fine if we were on rails >~ 2.3

require 'rubygems'
puts "installing gems..."

if !Gem.available?('rails')
  puts `gem install -v=2.1.2 rails`
end
GEMS={
  'aws-s3' => '0.6.2',
  'mime-types' => '1.16',
  'sunspot' => '1.1.0',
  'sunspot_rails' => '1.1.0',
  # needed to run `rake solr:sunspot:start`:
  'escape' => '0.0.4', 
  'nokogiri' => '1.5.0',
  # needed to run `thin start`
  'thin' => '1.2.11',
  'json' => '1.5.3',
  'capistrano' => '2.8.0',
  'capistrano-ext' => '1.2.1'
}
GEMS.each do |gem, version|
  cmd = "gem install -r --no-rdoc --no-ri #{gem} -v #{version}"
  puts `#{cmd}`
end

# install the above dependencies allows us to do this:
puts `rake gems:install`

puts "Done."