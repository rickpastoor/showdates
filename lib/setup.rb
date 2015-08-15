require 'sequel'
require 'bugsnag'

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
