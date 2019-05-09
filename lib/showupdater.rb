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
    showXML = TVDB.getShowXML(@show.tvdbid)

    # If we were not able to fetch XML, return
    return unless showXML

    parsedXml = Nokogiri::XML(showXML)
    show = parsedXml.xpath('/Data/Series')
    episodes = parsedXml.xpath('/Data/Episode')

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

    currentSeasonId = nil
    currentSeason = nil

    # Fix episodes/seasons
    episodes.each do |episode|
      next if episode.at_xpath('EpisodeName').content.empty?

      # Figure out the season
      if currentSeasonId != episode.at_xpath('seasonid').content
        currentSeason = SDSeason.find(tvdbid: episode.at_xpath('seasonid').content)

        currentSeason ||= SDSeason.create(
          tvdbid: episode.at_xpath('seasonid').content
        )

        currentSeason.title = episode.at_xpath('SeasonNumber').content
        currentSeason.order = episode.at_xpath('SeasonNumber').content
        currentSeason.show = @show
        currentSeason.save
      end

      ep = SDEpisode.find(tvdbid: episode.at_xpath('id').content)
      ep ||= SDEpisode.create(
        tvdbid: episode.at_xpath('id').content,
        created: DateTime.now
      )

      ep.season = currentSeason
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

    parsedBannerXml = Nokogiri::XML(TVDB.getShowBannerXML(@show.tvdbid))
    banners = parsedBannerXml.xpath('/Banners/Banner')

    bannerUrl = nil
    posterUrl = nil

    banners.each do |banner|
      # Pick the first item as our banner
      bannerUrl ||= banner.at_xpath('BannerPath').content

      if !posterUrl && banner.at_xpath('BannerType').content == 'poster'
        posterUrl = banner.at_xpath('BannerPath').content
      end

      break if bannerUrl && posterUrl
    end

    save_image(bannerUrl, @show.banner_path, 'banner')
    save_image(posterUrl, @show.poster_path, 'poster')

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
