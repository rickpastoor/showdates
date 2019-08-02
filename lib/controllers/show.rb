# frozen_string_literal: true

class ShowController < ShowdatesApp
  get '/:id', auth: :user do
    @show = SDShow[params[:id]]

    halt 404 unless @show

    @title = @show.title

    episode_builder = EpisodeBuilder.new(@user)
    @show_data = episode_builder.build_show(@show)

    erb :show
  end

  get '/:id/follow', auth: :user do
    show = SDShow[params[:id]]

    halt 404 unless show

    user_show = SDUserShow.find(user: @user, show: show)
    unless user_show
      SDUserShow.create(
        user: @user,
        show: show
      )
    end

    redirect request.referrer
  end

  get '/:id/unfollow', auth: :user do
    show = SDShow[params[:id]]

    halt 404 unless show

    @user.remove_following(show)

    redirect request.referrer
  end

  get '/season_watched/:season_id', auth: :user do
    season = SDSeason[params[:season_id]]

    halt 404 unless season

    local_time = @user.to_local_time(Time.now.getutc)

    season.episodes.each do |episode|
      # Only update the episode if it is in the past or if it is a special
      if episode.season.specials? || (episode.firstaired && local_time > @user.to_local_time(episode.firstaired.to_time))
        @user.update_episode(episode, true)
      end
    end

    redirect request.referrer
  end

  get '/season_unwatched/:season_id', auth: :user do
    season = SDSeason[params[:season_id]]

    halt 404 unless season

    season.episodes.each do |episode|
      @user.update_episode(episode, false)
    end

    redirect request.referrer
  end
end
