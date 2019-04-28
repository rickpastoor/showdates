# frozen_string_literal: true

require 'sequel'
require 'bugsnag'
require 'koala'
require 'twitter_oauth'
require 'aws/ses'

%w[
  BASE_URL
  DATABASE_URL
  SESSION_SECRET
].each { |env| raise LoadError, "missing: #{env}" if ENV[env].to_s.empty? }

# We're in UTC
ENV['TZ'] = 'UTC'

# Set up database connection
socket = ENV['DATABASE_SOCKET']
DB = Sequel.connect(ENV['DATABASE_URL'], :socket => socket, :max_connections => 10)

# Get gitref
ENV['gitref'] = begin
                  File.read('.mina_git_revision')
                rescue StandardError
                  nil
                end
ENV['gitref_short'] = ENV['gitref'][0..7] if ENV['gitref']

# Set up logging
if ENV['BUGSNAG_APIKEY']
  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_APIKEY']
    config.app_version = ENV['gitref'] if ENV['gitref']
    config.project_root = '/var/www/showdates.me/current'
  end
end

# Set up Koala
Koala.configure do |config|
  config.app_id = ENV['FACEBOOK_APP_ID']
  config.app_secret = ENV['FACEBOOK_APP_SECRET']
end
