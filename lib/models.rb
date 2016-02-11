require 'sequel'

class SDUser < Sequel::Model(:users)
  def check_password(password)
    self.password == `php php/whirlpool.php #{Shellwords.escape(password + ENV['PASSWORD_SALT'])}`
  end
end

class SDEpisode < Sequel::Model(:episodes)
end

class SDGenre < Sequel::Model(:genres)
  many_to_many :shows, { :class => :SDShow, :join_table => :show_genre, :left_key => :genre_id, :right_key => :show_id }
end

class SDNetwork < Sequel::Model(:networks)
end

class SDSeason < Sequel::Model(:seasons)
end

class SDShow < Sequel::Model(:shows)
  many_to_one :network
  many_to_many :genres, { :class => :SDGenre, :join_table => :show_genre, :left_key => :show_id, :right_key => :genre_id }
end
