require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'

require_relative 'lib/setup'
require_relative 'lib/models'

class ShowdatesApp < Sinatra::Base
  enable :sessions
  enable :raise_errors

  set :session_secret, ENV['SESSION_SECRET']
  set :sessions, :domain => ENV['COOKIE_DOMAIN']

  set :erb, :escape_html => true

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/*.rb'
    also_reload 'helpers/*.rb'
  end

  register do
    def auth (type)
      condition do
        redirect "/login" unless send("is_#{type}?")
      end
    end
  end

  helpers do
    # If @title is assigned, add it to the page's title.
    def title
      if @title
        "#{@title} / Menifesto"
      else
        "Menifesto"
      end
    end

    def is_user?
      @user != nil
    end

    def is_confirmed?
    	@user.confirmed == true
    end
  end

  before do
    @user = SDUser[session[:user_id]]
  end

  not_found do
    erb :'notfound'
  end

  error 500 do
    Bugsnag.auto_notify($!)
    erb :'error'
  end

  get '/' do
    if is_user?
      redirect '/couch'
    end

  	@title = 'Hallo!'

  	erb :'index'
  end
end
