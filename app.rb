# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'tzinfo'
require 'bcrypt'
require 'securerandom'

require 'setup'
require 'models'
require 'mailer'
require 'episodebuilder'
require 'helpers/style'
require 'helpers/markdown_template'

class ShowdatesApp < Sinatra::Base
  configure :production do
    use Bugsnag::Rack
  end

  use Rack::Session::Cookie,
      key: 'rack.session',
      path: '/',
      secret: ENV['SESSION_SECRET']

  enable :raise_errors
  enable :logging

  set :erb, escape_html: true

  register Sinatra::Flash

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/*.rb'
    also_reload 'lib/helpers/*.rb'
  end

  register do
    def auth(type)
      condition do
        redirect '/login' unless send("is_#{type}?")
      end
    end
  end

  helpers do
    # If @title is assigned, add it to the page's title.
    def title
      if @title
        "#{@title} / Showdates"
      else
        'Showdates'
      end
    end

    def description
      @description || 'Showdates helps you keep track of your favorite television shows. Record which episodes you have seen and always know when the next one will air.'
    end

    def is_user?
      @user != nil
    end

    def is_admin?
      !@user.nil? && @user.is_admin
    end
  end

  before do
    @user = SDUser[session[:user_id]]

    @mailer = Mailer.new
  end

  not_found do
    erb :notfound
  end

  error 500 do
    Bugsnag.auto_notify($ERROR_INFO)
    erb :error
  end

  get '/' do
    redirect '/couch' if is_user?

    @title = 'Welcome'

    erb :index
  end
end
