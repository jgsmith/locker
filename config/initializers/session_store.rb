# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_files_session',
  :secret      => 'ef132db103720c504bbb48e9a1cf79c4967234fbe9712958dadb682bf72d11bef12f2656b0f2167bafea26b9a0cb96585ca3f10080e1b40c39f79dcd208a51e7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
