class ShowsController < ShowdatesApp
  get '/' do
    @title = 'Shows'

    @popular_shows = SDShow.order(Sequel.desc(:followers)).limit(6)

    erb :'shows'
  end
end
