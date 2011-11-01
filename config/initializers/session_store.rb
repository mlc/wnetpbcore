# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wnetpbcore_session',
  :secret      => '6b137aee59b86083b83b694e7f3b9e4edf24efff9ef686ae7f0df819864856345261a04c3ef90c4caa9b2d3016e4170eac58f7882bc1dc75d05d0cbf80f3b464'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
