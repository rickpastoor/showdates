# frozen_string_literal: true

require 'sequel'
require 'carrierwave'
require 'carrierwave/sequel'
require 'mini_magick'

Sequel::Model.plugin :timestamps, update_on_create: true, create: :created, update: :edited

CarrierWave.configure do |config|
  config.root = File.expand_path '../public', __dir__
end

# Class for user avatar
class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process convert: 'png'
  process resize_to_fill: [400, 400]

  version :thumb do
    process resize_to_fill: [52, 52]
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end

  def filename
    "avatar.#{model.id}.png" if original_filename
  end

  def store_dir
    'uploads/users'
  end

  storage :file
end

# Describes a user
class SDUser < Sequel::Model(:users)
  many_to_many :following, class: :SDShow, join_table: :user_show, left_key: :user_id, right_key: :show_id
  one_to_many :episodes, class: :SDUserEpisode, key: :user_id
  mount_uploader :avatar, AvatarUploader

  def check_password(password)
    return self.password == BCrypt::Engine.hash_secret(password, salt) if password_migrated

    if self.password == `php php/whirlpool.php #{Shellwords.escape(password + ENV['PASSWORD_SALT'])}`
      # Migrate the old password safely
      self.salt = BCrypt::Engine.generate_salt
      self.password = BCrypt::Engine.hash_secret(password, salt)
      self.password_migrated = true
      save

      return true
    end

    false
  end

  def to_local_time(time)
    tz = TZInfo::Timezone.get(timezone || 'Europe/London')
    tz.utc_to_local(time)
  end

  def local_to_utc(time)
    tz = TZInfo::Timezone.get(timezone || 'Europe/London')
    tz.local_to_utc(time)
  end

  # Returns the current date as it is right now for this user
  def local_current_date
    Date.parse(to_local_time(Time.now.utc).to_s)
  end

  def providerurl_for_episode(episode)
    replacements = {
      '{show}' => episode.show.title,
      '{episodeCode}' => episode.season.specials? ? episode[:episode_title] : episode.episode_code,
      '{episodeCodeFull}' => episode.season.specials? ? episode[:episode_title] : episode.episode_code_full
    }

    providerurl.gsub(/{show}|{episodeCode}|{episodeCodeFull}/) { |m| replacements.fetch(m, m) }
  end

  def is_following(show)
    following.include?(show)
  end

  def avatar_thumb_url
    return ENV['BASE_URL'][0..-2] + avatar.thumb.url if avatar.thumb.url

    ENV['BASE_URL'][0..-2] + '/img/touch-icon-iphone-precomposed.png'
  end

  def update_episode(episode, watched)
    userEpisode = SDUserEpisode.find(user_id: id, episode_id: episode.id)

    if !userEpisode
      userEpisode = SDUserEpisode.new(
        user_id: id,
        episode_id: episode.id,
        watched: watched ? DateTime.now : nil
      )
    else
      watched ? userEpisode[:watched] = DateTime.now : userEpisode[:watched] = nil
    end

    userEpisode.save
  end

  # Returns a Time object which equals the next time this user should
  # get a new goal reminder (UTC time)
  def next_episode_reminder_time
    email_time = '12:00'

    user_next_email_time = Time.parse(local_current_date.to_s + ' ' + email_time)

    local_to_utc(user_next_email_time)
  end

  def should_receive_episode_reminder?
    return false unless sendemailnotice == 'yes'

    return false if emailaddress.nil?

    # If the user already had an email today, exit
    return false if lastemailnotice == local_current_date

    # Next email time for user?
    Time.now.utc > next_episode_reminder_time
  end
end

# Describes an episode
class SDEpisode < Sequel::Model(:episodes)
  many_to_one :show, class: :SDShow
  many_to_one :season, class: :SDSeason
  one_to_many :watchers, class: :SDUserEpisode, key: :episode_id

  def episode_code
    format('S%02dE%02d', season.title, order)
  end

  def episode_code_full
    format('season %d episode %d', season.title, order)
  end

  def firstaired_formatted(current_date: nil)
    return nil if firstaired.nil?

    current_date ||= Date.today

    date_difference = firstaired.to_date - current_date

    if date_difference.abs < 10
      if date_difference == 0
        return 'Today'
      elsif date_difference == 1
        return 'Tomorrow'
      elsif date_difference == -1
        return 'Yesterday'
      elsif date_difference < -1
        return "#{date_difference.abs.to_i} days ago"
      elsif date_difference > 1
        return "In #{date_difference.abs.to_i} days"
      end
    end

    firstaired.strftime('%d %b %Y')
  end

  def watched_by?(user:)
    userEpisode = SDUserEpisode.find(user_id: user.id, episode_id: id)
    userEpisode&.watched
  end
end

# Describes the relationship between user and episode
class SDUserEpisode < Sequel::Model(:user_episode)
  many_to_one :episode, class: :SDEpisode
end

# Describes a genre
class SDGenre < Sequel::Model(:genres)
  many_to_many :shows, class: :SDShow, join_table: :show_genre, left_key: :genre_id, right_key: :show_id
end

# Holds the network logo
class NetworkIconUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process convert: 'png'
  process resize_to_fill: [400, 400]

  version :thumb do
    process resize_to_fill: [52, 52]
  end

  def extension_white_list
    %w[jpg jpeg gif png]
  end

  def filename
    "icon.#{model.id}.png" if original_filename
  end

  def store_dir
    'uploads/networks'
  end

  storage :file
end

# Describes a network
class SDNetwork < Sequel::Model(:networks)
  one_to_many :shows, class: :SDShow, key: :network_id
  mount_uploader :icon, NetworkIconUploader

  def icon_thumb_url
    return ENV['BASE_URL'][0..-2] + icon.thumb.url if icon.thumb.url
  end
end

# Describes a season
class SDSeason < Sequel::Model(:seasons)
  one_to_many :episodes, class: :SDEpisode, key: :season_id, order: :order
  many_to_one :show, class: :SDShow

  def specials?
    title == '0'
  end

  def formatted_title
    return 'Specials' if specials?

    'Season ' + title
  end
end

# Describes a show
class SDShow < Sequel::Model(:shows)
  many_to_one :network, class: :SDNetwork
  many_to_many :genres, class: :SDGenre, join_table: :show_genre, left_key: :show_id, right_key: :genre_id
  one_to_many :seasons, class: :SDSeason, key: :show_id, order: :order
  one_to_many :episodes, class: :SDEpisode, key: :show_id
  many_to_many :followers, class: :SDUser, join_table: :user_show, left_key: :show_id, right_key: :user_id

  def banner_path
    "/uploads/shows/banner-#{id}.jpg"
  end

  def poster_path
    "/uploads/shows/poster-#{id}.jpg"
  end

  def poster_url
    return poster_path if File.file?("./public#{poster_path}")

    '/img/poster.png'
  end

  dataset_module do
    def most_popular(count = 10)
      order(Sequel.desc(:followers)).limit(count)
    end
  end
end

# Describes the relationship between a user and a show
class SDUserShow < Sequel::Model(:user_show)
  many_to_one :user, class: :SDUser
  many_to_one :show, class: :SDShow
end
