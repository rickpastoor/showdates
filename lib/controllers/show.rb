class ShowController < ShowdatesApp
  get '/:id' do
    @show = SDShow[params[:id]]
    @title = @show.title

    episodeBuilder = EpisodeBuilder.new(@user)
    @show_data = episodeBuilder.build_show(@show)

    erb :'show'
  end

  get '/:id/follow' do
    show = SDShow[params[:id]]

    userShow = SDUserShow.find(:user => @user, :show => show)
    if !userShow
      SDUserShow.create(
        :user => @user,
        :show => show
      )
    end

    redirect request.referrer
  end

  get '/:id/unfollow' do
    show = SDShow[params[:id]]

    @user.remove_following(show)

    redirect request.referrer
  end
end
