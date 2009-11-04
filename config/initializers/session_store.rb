# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_twenty4_session',
  :secret      => '67959a2607230357903b927ce941d807b458792fe24868bfb581e391717973e532640f3b9ac8ff1b73d25ae43a28211721ad5b09b4166f1afb0c8fa16e305e05'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
