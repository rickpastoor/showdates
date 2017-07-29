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

  get '/season_watched/:season_id' do
    season = SDSeason[params[:season_id]]

    local_time = @user.to_local_time(Time.now.getutc)

    season.episodes.each do |episode|
      # Only update the episode if it is in the past or if it is a special
      if episode.season.specials? || (episode.firstaired && local_time > @user.to_local_time(episode.firstaired.to_time))
        @user.update_episode(episode, true)
      end
    end

    redirect request.referrer
  end

  get '/season_unwatched/:season_id' do
    season = SDSeason[params[:season_id]]
    season.episodes.each do |episode|
      @user.update_episode(episode, false)
    end

    redirect request.referrer
  end
end
