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

    if user.check_password(params[:password])
      session[:user_id] = user.id

      redirect '/couch'
    end
  end
end
