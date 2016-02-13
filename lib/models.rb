require 'sequel'

class SDUser < Sequel::Model(:users)
  def check_password(password)
    self.password == `php php/whirlpool.php #{Shellwords.escape(password + ENV['PASSWORD_SALT'])}`
  end
end

class SDEpisode < Sequel::Model(:episodes)
  many_to_one :show, { :class => :SDShow }
  many_to_one :season, { :class => :SDSeason }
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
end
