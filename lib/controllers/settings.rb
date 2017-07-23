class SettingsController < ShowdatesApp
  get '/' do
    @title = 'Settings'

    erb :'settings'
  end
end
