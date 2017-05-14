class ShowController < ShowdatesApp
  get '/:id' do
    @show = SDShow[params[:id]]

    erb :'show'
  end
end
