# frozen_string_literal: true

class LoginController < ShowdatesApp
  get '/' do
    erb :login
  end

  post '/' do
    user = SDUser.find(emailaddress: params[:username])
    user ||= SDUser.find(username: params[:username])

    unless user
      flash[:error] = "We couldn't find a user with these credentials!"

      redirect '/login'
    end

    unless user.check_password(params[:password])
      flash[:error] = "We couldn't find a user with these credentials!"

      redirect '/login'
    end

    session[:user_id] = user.id

    redirect '/couch'
  end

  get '/facebook' do
    oauth = Koala::Facebook::OAuth.new

    if params[:code]
      graph = Koala::Facebook::API.new(oauth.get_access_token(params[:code], redirect_uri: ENV['BASE_URL'] + 'login/facebook'))

      profile = graph.get_object('me', fields: 'email,name')

      # Lets see if we have an account with this Facebook ID
      user = SDUser.find(facebook_id: profile['id'])
      user = SDUser.find(emailaddress: profile['email']) if !user && profile['email']

      # If we found someone, let's go
      if user
        user.emailaddress = profile['email'] unless user.emailaddress

        user.facebook_id = profile['id'] unless user.facebook_id

        user.save
      end

      # If not, create a new account
      user ||= SDUser.create(
        emailaddress: profile['email'],
        facebook_id: profile['id']
      )

      if user
        session[:user_id] = user.id

        redirect '/couch'
      else
        flash[:error] = 'Sorry, something went wrong while logging in.'

        redirect '/'
      end
    end

    redirect oauth.url_for_oauth_code(
      redirect_uri: ENV['BASE_URL'] + 'login/facebook',
      permissions: 'user_likes,email'
    )
  end

  get '/twitter' do
    client = TwitterOAuth::Client.new(
      consumer_key: ENV['TWITTER_CONSUMER_KEY'],
      consumer_secret: ENV['TWITTER_CONSUMER_SECRET']
    )

    if session[:twitter_rt_token] &&
       session[:twitter_rt_secret] &&
       params[:oauth_verifier]
      client.authorize(
        session[:twitter_rt_token],
        session[:twitter_rt_secret],
        oauth_verifier: params[:oauth_verifier]
      )

      session[:twitter_rt_token] = nil
      session[:twitter_rt_secret] = nil

      if client.authorized?
        user_info = client.info

        # Lets see if we have an account with this Twitter ID
        user = SDUser.find(twitter_user_id: user_info['id'])

        user ||= SDUser.create(
          twitter_user_id: user_info['id']
        )

        if user
          user.twitter_screen_name = user_info['screen_name']
          user.save

          session[:user_id] = user.id

          redirect '/couch'
        end

        flash[:error] = 'Sorry, something went wrong while logging in.'

        redirect '/'
      end
    end

    request_token = client.request_token(oauth_callback: ENV['BASE_URL'] + 'login/twitter')

    session[:twitter_rt_token] = request_token.token
    session[:twitter_rt_secret] = request_token.secret

    redirect request_token.authorize_url
  end
end
