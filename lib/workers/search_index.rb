# frozen_string_literal: true

require 'sidekiq'

class SearchIndexWorker
  include Sidekiq::Worker

  def perform
    begin
      file = File.new('./public/uploads/search_index.json', 'w+')

      search_index = []

      SDShow.exclude(title: '').each do |show|
        search_index << {
          id: show.id,
          title: show.title,
          poster: show.poster_url
        }
      end

      file.write(search_index.to_json)
    ensure
      file.close unless file.nil?
    end
  end
end
