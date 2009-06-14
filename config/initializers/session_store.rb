# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_northwest-digital-archives_session',
  :secret      => 'a09ecebf52c1a4d5d96cd0bb7c33d941151adf6d7ef3b2b9262fc9f64cc76308846afb7c78f1d0e1ccdf4e55a39419b70e39a8530400219f08062a6a057bf5b0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
