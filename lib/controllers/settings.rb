# frozen_string_literal: true

class SettingsController < ShowdatesApp
  get '/', auth: :user do
    @title = 'Settings'

    erb :settings
  end

  post '/', auth: :user do
    if params[:avatar]
      @user.avatar = params[:avatar]
    end

    @user.firstname = params[:firstname]
    @user.lastname = params[:lastname]
    @user.sendemailnotice = 'no'
    @user.sendemailnotice = 'yes' if params[:sendemailnotice] == 'on'
    @user.privacymode = params[:privacymode]
    @user.timezone = params[:timezone]
    @user.providerurl = params[:providerurl]

    @user.save

    flash[:success] = 'Your new settings have been saved succesfully.'

    redirect '/settings#' + params[:section] if params[:section]

    redirect request.referrer
  end

  get '/resetkey', auth: :user do
    @user.servicekey = SecureRandom.hex
    @user.save

    flash[:success] = 'You have a brand new servicekey!'

    redirect '/settings#servicekey'
  end
end
