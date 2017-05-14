class EpisodeController < ShowdatesApp
  get '/watched/:episode_id' do
    userEpisode = SDUserEpisode.find(:user_id => @user.id, :episode_id => params[:episode_id])

    if !userEpisode
      userEpisode = SDUserEpisode.new(
        :user_id => @user.id,
        :episode_id => params[:episode_id],
        :watched => DateTime.now
      )
    else
      userEpisode[:watched] = DateTime.now
    end

    userEpisode.save

    redirect request.referrer
  end
end
