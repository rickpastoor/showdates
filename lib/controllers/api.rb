# frozen_string_literal: true

class ApiController < ShowdatesApp
  post '/episode/:episode_id', auth: :user do
    watched = params[:watched] == 'true'

    user_episode = @user.update_episode(SDEpisode[params[:episode_id]], watched)

    {
      episode_id: params[:episode_id],
      watched: watched
    }.to_json
  end
end
