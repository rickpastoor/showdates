class SettingsController < ShowdatesApp
  get '/', :auth => :user do
    @title = 'Settings'

    erb :'settings'
  end

  post '/', :auth => :user do
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
