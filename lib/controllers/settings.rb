# frozen_string_literal: true

class SettingsController < ShowdatesApp
  get '/', auth: :user do
    @title = 'Settings'

    erb :settings
  end

  post '/', auth: :user do
    if params[:avatar]
      @user.avatar = params[:avatar]
      @user.save
    end

    flash[:success] = 'Your new settings have been saved succesfully.'

    redirect '/settings#' + params[:section] if params[:section]

    redirect request.referrer
  end
end
