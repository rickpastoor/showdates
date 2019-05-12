# frozen_string_literal: true

require_relative 'tvdb'
require 'nokogiri'
require 'httparty'

class ShowUpdater
  def initialize(show)
    @show = show
  end

  def update
    puts "going to update show ##{@show.id} (#{@show.title})"

    # If no tvdbid is set, we cannot update so we return
    return unless @show.tvdbid

    # Download content
    show_xml = TVDB.getShowXML(@show.tvdbid)

    # If we were not able to fetch XML, return
    return unless show_xml

    parsed_xml = Nokogiri::XML(show_xml)
    show = parsed_xml.xpath('/Data/Series')
    episodes = parsed_xml.xpath('/Data/Episode')

    # If we don't have a title and the remote XML has no title either, return
    # @TODO test on content without title
    return if @show.title && show.at_xpath('SeriesName').content.empty?

    @show.title = show.at_xpath('SeriesName').content
    @show.status = show.at_xpath('Status').content
    @show.description = show.at_xpath('Overview').content
    @show.language = show.at_xpath('Language').content
    @show.airsdayofweek = show.at_xpath('Airs_DayOfWeek').content
    @show.airstime = show.at_xpath('Airs_Time').content
    @show.contentrating = show.at_xpath('ContentRating').content
    @show.runtime = show.at_xpath('Runtime').content

    @show.firstaired = nil
    unless show.at_xpath('FirstAired').content.empty?
      @show.firstaired = DateTime.parse(show.at_xpath('FirstAired').content)
    end

    imdb_id = show.at_xpath('IMDB_ID').content
    @show.imdb_id = imdb_id if imdb_id =~ /^tt[0-9]{7}$/

    @show.invisible = 0

    @show.edited = DateTime.now

    @show.save

    # Set network
    network = SDNetwork.find(title: show.at_xpath('Network').content)
    network ||= SDNetwork.create(
      title: show.at_xpath('Network').content
    ).save
    @show.network = network

    # Fix genres
    @show.remove_all_genres
    parse_genres(show.at_xpath('Genre').content).each do |g|
      genre = SDGenre.find(title: g)
      genre ||= SDGenre.create(
        title: g
      ).save

      @show.add_genre(genre)
    end

    current_season_id = nil
    current_season = nil

    # Fix episodes/seasons
    episodes.each do |episode|
      next if episode.at_xpath('EpisodeName').content.empty?

      # Figure out the season
      if current_season_id != episode.at_xpath('seasonid').content
        current_season_id = episode.at_xpath('seasonid').content

        current_season = SDSeason.find(tvdbid: episode.at_xpath('seasonid').content)

        current_season ||= SDSeason.create(
          tvdbid: episode.at_xpath('seasonid').content
        )

        current_season.title = episode.at_xpath('SeasonNumber').content
        current_season.order = episode.at_xpath('SeasonNumber').content
        current_season.show = @show
        current_season.save
      end

      ep = SDEpisode.find(tvdbid: episode.at_xpath('id').content)
      ep ||= SDEpisode.create(
        tvdbid: episode.at_xpath('id').content,
        created: DateTime.now
      )

      ep.season = current_season
      ep.show = @show
      ep.title = episode.at_xpath('EpisodeName').content
      ep.description = episode.at_xpath('Overview').content
      ep.language = episode.at_xpath('Language').content

      imdb_id = episode.at_xpath('IMDB_ID').content
      ep.imdb_id = imdb_id if imdb_id =~ /^tt[0-9]{7}$/

      ep.airsbefore_season = nil
      ep.airsbefore_season = episode.at_xpath('airsbefore_season').content if episode.at_xpath('airsbefore_season')

      ep.airsbefore_episode = nil
      ep.airsbefore_episode = episode.at_xpath('airsbefore_episode').content if episode.at_xpath('airsbefore_episode')

      ep.order = episode.at_xpath('EpisodeNumber').content

      ep.firstaired = nil
      unless episode.at_xpath('FirstAired').content.empty?
        ep.firstaired = DateTime.parse(episode.at_xpath('FirstAired').content)
      end

      ep.edited = DateTime.now

      ep.save
    end

    print 'updating banners...'

    parsed_banner_xml = Nokogiri::XML(TVDB.getShowBannerXML(@show.tvdbid))
    banners = parsed_banner_xml.xpath('/Banners/Banner')

    banner_url = nil
    poster_url = nil

    banners.each do |banner|
      # Pick the first item as our banner
      banner_url ||= banner.at_xpath('BannerPath').content

      if !poster_url && banner.at_xpath('BannerType').content == 'poster'
        poster_url = banner.at_xpath('BannerPath').content
      end

      break if banner_url && poster_url
    end

    save_image(banner_url, @show.banner_path, 'banner')
    save_image(poster_url, @show.poster_path, 'poster')

    print "done\n"
  end

  private

  def parse_genres(genre_string)
    genre_string.split('|').reject(&:empty?)
  end

  def save_image(url, path, _type)
    File.write(File.expand_path("public#{path}"), HTTParty.get("http://www.thetvdb.com/banners/#{url}").body)
  end
end
