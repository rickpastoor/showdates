# frozen_string_literal: true

class EpisodeBuilder
  def initialize(user)
    @user = user
  end

  def build_couch(show_id: nil)
    # Fetch the dataset we need
    episodes_dataset = SDEpisode.from_self(alias: :episodes)
                                .left_join(:user_episode, episode_id: Sequel[:episodes][:id], user_id: @user.id)
                                .join(:user_show, show_id: Sequel[:episodes][:show_id], user_id: @user.id)
                                .join(:seasons, { Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id) }, table_alias: :seasons)
                                .where(Sequel.qualify(:user_episode, :watched) => nil)
                                .exclude(Sequel.qualify(:episodes, :firstaired) => nil)
                                .exclude(Sequel.qualify(:episodes, :title) => '')
                                .exclude(Sequel.qualify(:seasons, :title) => '0')
                                .order(Sequel.qualify(:episodes, :show_id), Sequel.qualify(:seasons, :order), Sequel.qualify(:episodes, :order))
                                .select(
                                  Sequel[:episodes][:id],
                                  Sequel[:episodes][:title],
                                  Sequel[:user_episode][:watched],
                                  Sequel[:episodes][:firstaired],
                                  Sequel[:episodes][:show_id],
                                  Sequel[:episodes][:season_id],
                                  Sequel[:episodes][:order]
                                )

    if show_id
      episodes_dataset = episodes_dataset.where(Sequel.qualify(:episodes, :show_id) => show_id)
    end

    episodes = {}

    local_time = @user.to_local_time(Time.now.getutc)

    episodes_dataset.each do |episode|
      if !episodes[episode.show_id]
        episodes.store(episode.show_id,
                       queue: 1,
                       episode: episode,
                       aired: local_time > @user.to_local_time(episode.firstaired.to_time),
                       firstaired: episode.firstaired)
      else
        episodes[episode.show_id][:queue] = episodes[episode.show_id][:queue] + 1
      end
    end

    # Sort dataset
    episodes = episodes.sort_by { |_show, hash| hash[:firstaired] }

    # Split episodes
    {
      all: episodes,
      aired: episodes.select { |_show, hash| hash[:aired] },
      tobeaired: episodes.reject { |_show, hash| hash[:aired] }
    }
  end

  def build_show(show)
    # Fetch episode stuff
    episodes_dataset = SDEpisode.from_self(alias: :episodes)
                                .left_join(:user_episode, episode_id: Sequel[:episodes][:id], user_id: @user.id)
                                .join(:seasons, { Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id) }, table_alias: :seasons)
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

    seasons = {}

    episodes_dataset.each do |episode|
      if !seasons[episode.season_id]
        seasons.store(episode.season_id,
                      count: 1,
                      seen: episode[:watched] ? 1 : 0)
      else
        seasons[episode.season_id][:count] = seasons[episode.season_id][:count] + 1
        seasons[episode.season_id][:seen] = seasons[episode.season_id][:seen] + 1 if episode[:watched]
      end
    end

    {
      episodes: episodes_dataset,
      seasons: seasons
    }
  end

  def build_calendarfeed
    # Fetch the dataset we need
    episodes_dataset = SDEpisode.from_self(alias: :episodes)
                                .left_join(:user_episode, episode_id: Sequel[:episodes][:id], user_id: @user.id)
                                .join(:user_show, show_id: Sequel[:episodes][:show_id], user_id: @user.id)
                                .join(:seasons, { Sequel.qualify(:seasons, :id) => Sequel.qualify(:episodes, :season_id) }, table_alias: :seasons)
                                .exclude(Sequel.qualify(:episodes, :firstaired) => nil)
                                .exclude(Sequel.qualify(:episodes, :title) => '')
                                .exclude(Sequel.qualify(:seasons, :title) => '0')
                                .where(firstaired: (Date.today - 30)..(Date.today + 30))
                                .order(Sequel.qualify(:episodes, :firstaired))
                                .select(
                                  Sequel[:episodes][:id],
                                  Sequel[:episodes][:title],
                                  Sequel[:episodes][:description],
                                  Sequel[:user_episode][:watched],
                                  Sequel[:episodes][:firstaired],
                                  Sequel[:episodes][:show_id],
                                  Sequel[:episodes][:season_id],
                                  Sequel[:episodes][:order]
                                )

    episodes_dataset
  end

  def build_airingtoday
    episodes = build_couch[:all]

    episodes.select do |_show, hash|
      @user.to_local_time(hash[:firstaired].to_time).to_date == @user.to_local_time(Time.now.getutc).to_date
    end
            .map { |_key, value| value[:episode] }
            .map do |h|
      {
        'id' => h.id,
        'title' => h.title,
        'show_id' => h.show.id,
        'show_title' => h.show.title,
        'poster_url' => h.show.poster_url,
        'season_no' => h.season.title,
        'order' => h.order
      }
    end
  end

  def build_next_episode_for_show(show_id:)
    episodes = build_couch(show_id: show_id)

    return nil if episodes[:all].count.zero?

    episodes[:all].first[1]
  end
end
