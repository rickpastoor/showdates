class ShowsController < ShowdatesApp
  get '/', :auth => :user do
    @title = 'Shows'

    @popular_shows = SDShow.order(Sequel.desc(:followers)).limit(6)

    erb :'shows'
  end
end
