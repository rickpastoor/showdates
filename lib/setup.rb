require 'sequel'
require 'bugsnag'
require 'koala'
require 'twitter_oauth'

# Set up database connection
socket = ENV['DATABASE_SOCKET']
DB = Sequel.connect(ENV['DATABASE_URL'], :socket => socket, :max_connections => 10)

# Set up logging
if ENV['BUGSNAG_APIKEY']
  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_APIKEY']
    #config.release_stage = "development" if Sinatra::Base.development? Doesn't work on CLI
  end
end

# Set up Koala
Koala.configure do |config|
  config.app_id = ENV['FACEBOOK_APP_ID']
  config.app_secret = ENV['FACEBOOK_APP_SECRET']
end
