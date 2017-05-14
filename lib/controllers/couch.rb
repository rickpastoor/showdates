class CouchController < ShowdatesApp
  get '/' do
    couchBuilder = CouchBuilder.new(@user)
    @couch = couchBuilder.build

    @title = 'Couch'

    erb :'couch'
  end
end
