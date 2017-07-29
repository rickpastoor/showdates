class SettingsController < ShowdatesApp
  get '/' do
    @title = 'Settings'

    erb :'settings'
  end

  post '/' do
    if params[:avatar]
      @user.avatar = params[:avatar]
      @user.save
    end

    flash[:success] = 'Your new settings have been saved succesfully.'

    if params[:section]
      redirect '/settings#' + params[:section]
    end

    redirect request.referrer
  end
end
