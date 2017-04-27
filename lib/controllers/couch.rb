class CouchController < ShowdatesApp
  get '/' do
    couchBuilder = CouchBuilder.new(@user)
    @couch = couchBuilder.build

    erb :'couch'
  end
end
