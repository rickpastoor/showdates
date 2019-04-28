class FeedController < ShowdatesApp
  get '/ical/user\::user_id/key\::key' do
    @user = SDUser.find(servicekey: params[:key])
    halt 401 unless @user

    @local_time = @user.to_local_time(Time.now.getutc)

    episodeBuilder = EpisodeBuilder.new(@user)
    @episodes = episodeBuilder.build_calendarfeed

    erb :feed_ical, :layout => false
  end
end
