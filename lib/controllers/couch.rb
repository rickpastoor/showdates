class CouchController < ShowdatesApp
  get '/' do
    episodeBuilder = EpisodeBuilder.new(@user)
    @couch = episodeBuilder.build_couch

    @title = 'Couch'

    erb :'couch'
  end
end
