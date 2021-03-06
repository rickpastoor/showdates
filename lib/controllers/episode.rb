# frozen_string_literal: true

class EpisodeController < ShowdatesApp
  get '/:episode_id' do
    @episode = SDEpisode[params[:episode_id]]

    halt 404 unless @episode

    @title = @episode.title + ' - ' + @episode.show.title

    erb :episode
  end

  get '/watched/:episode_id', auth: :user do
    @user.update_episode(SDEpisode[params[:episode_id]], true)

    redirect request.referrer
  end

  get '/unwatched/:episode_id', auth: :user do
    @user.update_episode(SDEpisode[params[:episode_id]], false)

    redirect request.referrer
  end
end
