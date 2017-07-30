class CouchController < ShowdatesApp
  get '/', :auth => :user do
    episodeBuilder = EpisodeBuilder.new(@user)
    @couch = episodeBuilder.build_couch

    @title = 'Couch'

    erb :'couch'
  end
end
