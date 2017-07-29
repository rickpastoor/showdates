class AdminController < ShowdatesApp
  get '/', :auth => :admin do
    erb :'admin'
  end

  get '/networks', :auth => :admin do
    @networks = SDNetwork.all

    erb :'admin_networks'
  end

  get '/network/:id/edit', :auth => :admin do
    @network = SDNetwork[params[:id]]

    erb :'admin_network_edit'
  end

  post '/network/:id/edit', :auth => :admin do
    network = SDNetwork[params[:id]]

    if params[:icon]
      network.icon = params[:icon]
      network.save
    end

    flash[:success] = 'Network changes saved.'

    redirect request.referrer
  end
end
