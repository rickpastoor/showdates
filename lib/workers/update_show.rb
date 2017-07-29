require 'sidekiq'
require_relative '../showupdater'

class ShowWorker
  include Sidekiq::Worker

  def perform(thetvdb_id)
    show = SDShow.find(tvdbid: thetvdb_id)

    if !show
      show = SDShow.create(
        :tvdbid => thetvdb_id
      )
    end

    if show
      showUpdater = ShowUpdater.new(show)
      showUpdater.update
    end
  end
end
