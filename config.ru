require 'rubygems'
require 'sinatra'
require 'dotenv'
Dotenv.load

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

require './app.rb'
#require 'sidekiq/web'

Dir.glob('./lib/controllers/*.rb').each { |file| require file }

#Sidekiq::Web.use Rack::Session::Cookie, :secret => ENV['RACK_SESSION_COOKIE']

# Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
#   [user, password] == [ENV['SIDEKICK_ADMIN'], ENV['SIDEKICK_PASSWORD']]
# end

# Sidekiq::Web.instance_eval { @middleware.reverse! } # Last added, First Run

run Rack::URLMap.new({
  '/' => ShowdatesApp,
  '/account' => AccountController,
  '/couch' => CouchController,
  '/login' => LoginController,
  '/show' => ShowController,
  '/episode' => EpisodeController,
  #'/profile' => ProfileController,
  #'/signup' => SignupController,
#  '/sidekiq' => Sidekiq::Web
})
