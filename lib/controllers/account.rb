# frozen_string_literal: true

class AccountController < ShowdatesApp
  get '/logout' do
    session[:user_id] = nil

    redirect '/'
  end

  get '/resetpassword' do
    erb :account_resetpassword
  end

  post '/resetpassword' do
    user = SDUser.find(emailaddress: params[:emailaddress])

    user ||= SDUser.find(username: params[:emailaddress])

    unless user
      flash[:error] = 'We could not find an account associated with the given username/e-mailaddress.'
      redirect '/'
    end

    user.reset_key = SecureRandom.hex
    user.save

    email_template = MarkdownTemplate.render('emails/reset_password',
                                             'user_firstname' => user.firstname,
                                             'reset_key' => user.reset_key)

    @mailer.send_mail(
      recipient_email: user.emailaddress,
      subject: email_template[:config]['subject'],
      html: email_template[:template],
      async: false
    )

    flash[:error] = 'Hooray. Instructions on how to reset your password have been sent!'
    redirect '/'
  end

  get '/setpassword/:key' do
    user = SDUser.find(reset_key: params[:key])

    unless user
      flash[:error] = 'Something went wrong while resetting your password. Please try again.'
      redirect '/'
    end

    erb :account_setpassword
  end

  post '/setpassword/:key' do
    user = SDUser.find(reset_key: params[:key])

    unless user
      flash[:error] = 'Something went wrong while resetting your password. Please try again.'
      redirect '/'
    end

    if params[:password].empty? || params[:password_confirm].empty?
      flash[:error] = 'Please fill out both fields.'
      redirect request.referrer
    end

    if params[:password] != params[:password_confirm]
      flash[:error] = 'Passwords need to match!'
      redirect request.referrer
    end

    salt = BCrypt::Engine.generate_salt

    user.reset_key = nil
    user.password = BCrypt::Engine.hash_secret(params[:password], salt)
    user.password_migrated = true
    user.salt = salt
    user.save

    flash[:error] = 'Your password was set! You can log in now.'
    redirect '/login'
  end

  get '/unsubscribe/:key' do
    user = SDUser.find(reminder_email_unsubscribe_key: params[:key])

    unless user
      flash[:error] = 'Something went wrong updating your email settings.'
      redirect '/'
    end

    user.sendemailnotice = 'no'
    user.save

    flash[:success] = 'Settings saved. You won\'t receive episode reminders anymore.'
    redirect '/'
  end
end
