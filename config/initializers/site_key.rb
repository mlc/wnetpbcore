# instead of storing a site key in the source (which would then be visible to
# anyone who could see the source), we generate one the first time the app
# is run. this strategy requires modification if we have more than one app
# server talking to the same database.

SITE_KEY_FILENAME = "#{RAILS_ROOT}/config/site_key.txt"

if File.exist?(SITE_KEY_FILENAME)
  REST_AUTH_SITE_KEY = File.read(SITE_KEY_FILENAME)
else
  require 'rails_generator/secret_key_generator'
  REST_AUTH_SITE_KEY = Rails::SecretKeyGenerator.new(ENV['ID']).generate_secret
  File.open(SITE_KEY_FILENAME, "w", 0600) do |f|
    f.write REST_AUTH_SITE_KEY
  end
end

REST_AUTH_DIGEST_STRETCHES = 10