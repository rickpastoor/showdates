class SignupController < ShowdatesApp
  get '/' do
    erb :'signup'
  end

  post '/' do
    # Check required fields
    if params[:emailaddress].empty? || params[:password].empty? || params[:password_confirm].empty?
      flash[:error] = "Please fill in the required fields!"

      redirect '/signup'
    end

    # Check username format

    # Check username availability

    # Check if this emailaddress is already in use
    if SDUser.find(:emailaddress => params[:emailaddress])
      flash[:error] = "This emailaddress is already taken. Do you want to <a href=\"/login\"><strong>login</strong></a> instead?"

      redirect '/signup'
    end

    # Check if the passwords match
    if params[:password] != params[:password_confirm]
      flash[:error] = "The passwords do not match."

      redirect '/signup'
    end

    salt = BCrypt::Engine.generate_salt

    user = SDUser.create(
      :firstname => params[:firstname],
      :lastname => params[:lastname],
      :emailaddress => params[:emailaddress],
      :password => BCrypt::Engine.hash_secret(params[:password], salt),
      :password_migrated => true,
      :salt => salt,
      :timezone => 'Europe/London',
      :privacymode => 'public',
      :username => params[:username],
      :servicekey => SecureRandom.hex
    )

    session[:user_id] = user.id

    # Send welcome email

    redirect '/couch'
  end
end
