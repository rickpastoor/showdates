class ShowController < ShowdatesApp
  get '/:id' do
    @show = SDShow[params[:id]]

    # Fetch the dataset we need
    @episodes_dataset = SDEpisode.from_self(:alias => :episodes)
      .left_join(SDUserEpisode, [Sequel.qualify(:episodes, :id) => :episode_id, :user_id => @user.id])
      .join(:user_show, [Sequel.qualify(:user_show, :show_id) => Sequel.qualify(:episodes, :show_id), Sequel.qualify(:user_show, :user_id) => @user.id])
      .join(SDSeason, {Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id)}, :table_alias => :seasons)
      .where(:episodes__show_id => params[:id])
      .order(Sequel.qualify(:episodes, :show_id), Sequel.qualify(:seasons, :order), Sequel.qualify(:episodes, :order))
      .select(:episodes__id, :episodes__title___episode_title, :user_episode__watched, :episodes__firstaired, :episodes__show_id, :episodes__season_id, :episodes__order, :seasons__title___season_title)

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
