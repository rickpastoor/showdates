# frozen_string_literal: true

class ApiController < ShowdatesApp
  post '/episode/:episode_id/?:fetch_next?', auth: :user do
    watched = params[:watched] == 'true'

    episode = SDEpisode[params[:episode_id]]

    user_episode = @user.update_episode(episode, watched)

    result = {
      episode_id: params[:episode_id],
      watched: watched
    }

    return result.to_json if !watched || !params[:fetch_next]

    episodeBuilder = EpisodeBuilder.new(@user)
    next_episode = episodeBuilder.build_next_episode_for_show(show_id: episode.show_id)

    return result.to_json unless next_episode

    result[:next_episode] = next_episode[:episode].to_hash
    result[:next_episode][:queue] = next_episode[:queue]
    result[:next_episode][:aired] = next_episode[:aired]
    result[:next_episode][:show_title] = episode.show.title
    result[:next_episode][:timestamp] = next_episode[:episode].firstaired.to_time.to_i
    result[:next_episode][:firstaired_formatted] = next_episode[:episode].firstaired_formatted(current_date: @user.to_local_time(Time.now.getutc).to_date)
    result[:next_episode][:episode_code] = next_episode[:episode].episode_code
    result[:next_episode][:providerurl] = @user.providerurl_for_episode(next_episode[:episode])

    result.to_json
  end
end
