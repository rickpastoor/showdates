class EpisodeBuilder
  def initialize(user)
    @user = user
  end

  def build_couch
    # Fetch the dataset we need
    episodes_dataset = SDEpisode.from_self(:alias => :episodes)
      .left_join(SDUserEpisode, [Sequel.qualify(:episodes, :id) => :episode_id, :user_id => @user.id])
      .join(:user_show, [Sequel.qualify(:user_show, :show_id) => Sequel.qualify(:episodes, :show_id), Sequel.qualify(:user_show, :user_id) => @user.id])
      .join(SDSeason, {Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id)}, :table_alias => :seasons)
      .where(Sequel.qualify(:user_episode, :watched) => nil)
      .exclude(Sequel.qualify(:episodes, :firstaired) => nil)
      .exclude(Sequel.qualify(:episodes, :title) => '')
      .exclude(Sequel.qualify(:seasons, :title) => '0')
      .order(Sequel.qualify(:episodes, :show_id), Sequel.qualify(:seasons, :order), Sequel.qualify(:episodes, :order))
      .select(:episodes__id, :episodes__title, :user_episode__watched, :episodes__firstaired, :episodes__show_id, :episodes__season_id, :episodes__order)

    episodes = Hash.new

    local_time = @user.to_local_time(Time.now.getutc)

    episodes_dataset.each do |episode|
      if !episodes[episode.show_id]
        episodes.store(episode.show_id, {
          :queue => 1,
          :episode => episode,
          :aired => local_time > @user.to_local_time(episode.firstaired.to_time),
          :firstaired => episode.firstaired
        })
      else
        episodes[episode.show_id][:queue] = episodes[episode.show_id][:queue] + 1
      end
    end

    # Sort dataset
    episodes.sort_by { |show, hash| hash[:firstaired] }

    # Split episodes
    {
      :aired => episodes.select { |show, hash| hash[:aired] },
      :tobeaired => episodes.select { |show, hash| !hash[:aired] }
    }
  end

  def build_show(show)
    # Fetch episode stuff
    episodes_dataset = SDEpisode.from_self(:alias => :episodes)
      .left_join(:user_episode, episode_id: Sequel[:episodes][:id], :user_id => @user.id)
      .join(:seasons, {Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id)}, :table_alias => :seasons)
      .where(Sequel.qualify(:episodes, :show_id) => show.id)
      .order(Sequel.qualify(:episodes, :show_id), Sequel.qualify(:seasons, :order), Sequel.qualify(:episodes, :order))
      .select(
        Sequel[:episodes][:id],
        Sequel.as(Sequel[:episodes][:title], :episode_title),
        Sequel[:user_episode][:watched],
        Sequel[:episodes][:firstaired],
        Sequel[:episodes][:show_id],
        Sequel[:episodes][:season_id],
        Sequel[:episodes][:order],
        Sequel.as(Sequel[:seasons][:title], :season_title)
      )

    seasons = Hash.new

    episodes_dataset.each do |episode|
      if !seasons[episode.season_id]
        seasons.store(episode.season_id, {
          :count => 1,
          :seen => episode[:watched] ? 1 : 0
        })
      else
        seasons[episode.season_id][:count] = seasons[episode.season_id][:count] + 1
        if episode[:watched]
          seasons[episode.season_id][:seen] = seasons[episode.season_id][:seen] + 1
        end
      end
    end

    {
      :episodes => episodes_dataset,
      :seasons => seasons
    }
  end
end
