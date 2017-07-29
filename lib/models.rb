require 'sequel'
require 'carrierwave'
require 'carrierwave/sequel'
require 'mini_magick'

Sequel::Model.plugin :timestamps, :update_on_create => true, :create => :created, :update => :edited

CarrierWave.configure do |config|
  config.root = File.expand_path '../../public', __FILE__
end

# uploader
class AvatarUploader < CarrierWave::Uploader::Base
	include CarrierWave::MiniMagick
	process convert: 'png'
	process resize_to_fill: [400, 400]

	version :thumb do
    process :resize_to_fill => [52, 52]
  end

	def extension_white_list
    %w(jpg jpeg gif png)
  end

	def filename
    "avatar.#{model.id}.png" if original_filename
  end

  def store_dir
    'uploads/users'
  end

	storage :file
end

class SDUser < Sequel::Model(:users)
  many_to_many :following, { :class => :SDShow, :join_table => :user_show, :left_key => :user_id, :right_key => :show_id }
  mount_uploader :avatar, AvatarUploader

  def check_password(password)
    self.password == `php php/whirlpool.php #{Shellwords.escape(password + ENV['PASSWORD_SALT'])}`
  end

  def to_local_time(time)
    tz = TZInfo::Timezone.get(self.timezone)
    tz.utc_to_local(time)
  end

  def providerurl_for_episode(episode)
    replacements = {
      "{show}" => episode.show.title,
      "{episodeCode}" => episode.episode_code,
      "{episodeCodeFull}" => episode.episode_code_full
    }

    self.providerurl.gsub(/{show}|{episodeCode}|{episodeCodeFull}/) { |m| replacements.fetch(m,m)}
  end

  def is_following(show)
    self.following.include?(show)
  end

  def avatar_thumb_url
    if avatar.thumb.url
      return ENV['BASE_URL'][0..-2] + avatar.thumb.url
    end

    ENV['BASE_URL'][0..-2] + "/img/touch-icon-iphone-precomposed.png"
  end
end

class SDEpisode < Sequel::Model(:episodes)
  many_to_one :show, { :class => :SDShow }
  many_to_one :season, { :class => :SDSeason }
  one_to_many :watchers, { :class => :SDUserEpisode }

  def episode_code
    sprintf('S%02dE%02d', self.season.title, self.order);
  end

  def episode_code_full
    sprintf('season %d episode %d', self.season.title, self.order);
  end
end

class SDUserEpisode < Sequel::Model(:user_episode)
  many_to_one :episode, { :class => :SDEpisode }
end

class SDGenre < Sequel::Model(:genres)
  many_to_many :shows, { :class => :SDShow, :join_table => :show_genre, :left_key => :genre_id, :right_key => :show_id }
end

class SDNetwork < Sequel::Model(:networks)
  one_to_many :shows, { :class => :SDShow }
end

class SDSeason < Sequel::Model(:seasons)
  one_to_many :episodes, { :class => :SDEpisode, :key => :season_id, :order => :order }
  many_to_one :show, { :class => :SDShow }

  def specials?
    title == '0'
  end

  def formatted_title
    if specials?
      return 'Specials'
    end

    'Season ' + title
  end
end

class SDShow < Sequel::Model(:shows)
  many_to_one :network, { :class => :SDNetwork }
  many_to_many :genres, { :class => :SDGenre, :join_table => :show_genre, :left_key => :show_id, :right_key => :genre_id }
  one_to_many :seasons, { :class => :SDSeason, :key => :show_id, :order => :order }
  one_to_many :episodes, { :class => :SDEpisode, :key => :show_id }
  many_to_many :followers, { :class => :SDUser, :join_table => :user_show, :left_key => :show_id, :right_key => :user_id }

  def banner_path
    "/uploads/shows/#{self.id}-banner.jpg"
  end

  def poster_path
    "/uploads/shows/#{self.id}-poster.jpg"
  end
end

class SDUserShow < Sequel::Model(:user_show)
  many_to_one :user, { :class => :SDUser }
  many_to_one :show, { :class => :SDShow }
end
