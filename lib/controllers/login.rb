class LoginController < ShowdatesApp
  get '/' do
    erb :'login'
  end

  post '/' do
    user = SDUser.find(:emailaddress => params[:username])
    if !user
      user = SDUser.find(:username => params[:username])
    end

    if !user
      flash[:error] = "We couldn't find a user with these credentials!"

      redirect '/login'
    end

    if !user.check_password(params[:password])
      flash[:error] = "We couldn't find a user with these credentials!"

      redirect '/login'
    end

    session[:user_id] = user.id

    redirect '/couch'
  end

  get '/facebook' do
    oauth = Koala::Facebook::OAuth.new()

    if params[:code]
      graph = Koala::Facebook::API.new(oauth.get_access_token(params[:code], { :redirect_uri => ENV['BASE_URL'] + 'login/facebook'}))

      profile = graph.get_object('me', fields: 'email,name')

      # Lets see if we have an account with this Facebook ID
      user = SDUser.find(:facebook_id => profile['id'])
      if !user
        user = SDUser.find(:emailaddress => profile['email'])
      end

      # If we found someone, let's go
      if user
        if !user.emailaddress
          user.emailaddress = profile['email']
        end

        if !user.facebook_id
          user.facebook_id = profile['id']
        end

        user.save
      end

      # If not, create a new account
      if !user
        user = SDUser.create(
          :emailaddress => profile['email'],
          :facebook_id => profile['id']
        )
      end

      if user
        session[:user_id] = user.id

        redirect '/couch'
      else
        flash[:error] = 'Sorry, something went wrong while loggin in.'

        redirect '/'
      end
    end

    redirect oauth.url_for_oauth_code(
      :redirect_uri => ENV['BASE_URL'] + 'login/facebook',
      :permissions => 'user_likes,email'
    )
  end
end
