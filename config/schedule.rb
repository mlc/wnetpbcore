# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Learn more: http://github.com/javan/whenever

set :cron_log, "#{RAILS_ROOT}/log/cron_log.log"

every 8.hours, :at => 37 do
  rake "ts:in"
end

every :reboot do
  rake 'ts:start'
end
