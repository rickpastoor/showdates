class SignupController < ShowdatesApp
  get '/' do
    erb :'signup'
  end

  post '/' do
    # Check required fields

    # Check username format

    # Check username availability

    # Check if this emailaddress is already in use

    # Check if the passwords match

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
