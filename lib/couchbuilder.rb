class CouchBuilder
  def initialize(user)
    @user = user
  end

  def build
    # Fetch the dataset we need
    episodes_dataset = SDEpisode.left_join(SDUserEpisode, [Sequel.qualify(:episodes, :id) => :episode_id, :user_id => @user.id])
      .join(:user_show, [Sequel.qualify(:user_show, :show_id) => Sequel.qualify(:episodes, :show_id), Sequel.qualify(:user_show, :user_id) => @user.id])
      .join(SDSeason, Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id))
      .where(Sequel.qualify(:user_episode, :watched) => nil)
      .exclude(Sequel.qualify(:episodes, :firstaired) => nil)
      .exclude(Sequel.qualify(:episodes, :title) => '')
      .exclude(Sequel.qualify(:seasons, :title) => '0')
      .order(Sequel.qualify(:episodes, :show_id), Sequel.qualify(:seasons, :order), Sequel.qualify(:episodes, :order))

    episodes = Hash.new

    local_time = @user.to_local_time(Time.now.getutc)

    episodes_dataset.each do |episode|
      if !episodes[episode.show_id]
        episodes.store(episode.show_id, {
          :queue => 1,
          :episode => episode,
          :aired => local_time > @user.to_local_time(episode.firstaired.to_time)
        })
      else
        episodes[episode.show_id][:queue] = episodes[episode.show_id][:queue] + 1
      end
    end

    episodes
  end
end
