# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'dotenv'
Dotenv.load

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

ROOT_DIR = File.expand_path('./lib', __dir__)
$LOAD_PATH.unshift ROOT_DIR

require './app.rb'
require 'sidekiq/web'

if ENV['RACK_ENV'] == 'development'
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end

Dir.glob('./lib/controllers/*.rb').each { |file| require file }

Sidekiq::Web.use Rack::Session::Cookie, :secret => ENV['RACK_SESSION_COOKIE']

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
   [user, password] == [ENV['SIDEKICK_ADMIN'], ENV['SIDEKICK_PASSWORD']]
end

# Sidekiq::Web.instance_eval { @middleware.reverse! } # Last added, First Run

run Rack::URLMap.new({
  '/' => ShowdatesApp,
  '/account' => AccountController,
  '/couch' => CouchController,
  '/login' => LoginController,
  '/show' => ShowController,
  '/shows' => ShowsController,
  '/episode' => EpisodeController,
  '/settings' => SettingsController,
  '/admin' => AdminController,
  #'/profile' => ProfileController,
  '/signup' => SignupController,
  '/sidekiq' => Sidekiq::Web
})
