class ShowController < ShowdatesApp
  get '/:id/:slug' do
    @show = SDShow[params[:id]]

    erb :'show'
  end
end
