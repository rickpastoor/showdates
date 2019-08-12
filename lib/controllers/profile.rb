# frozen_string_literal: true

class ProfileController < ShowdatesApp
  get '/:id' do
    @active_user = SDUser.find(username: params[:id])

    @active_user = SDUser[params[:id]] unless @active_user

    halt 404 unless @active_user

    return erb :profile_private unless @active_user.privacymode == 'public' || @active_user == @user

    @following_shows = @active_user.following.reverse

    @episodes = @active_user.episodes_dataset.exclude(watched: nil).reverse(:watched).limit(20)

    erb :profile
  end
end
