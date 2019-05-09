# frozen_string_literal: true

require 'sidekiq'
require 'showupdater'

class ShowWorker
  include Sidekiq::Worker

  def perform(thetvdb_id)
    show = SDShow.find(tvdbid: thetvdb_id)

    show ||= SDShow.create(
      tvdbid: thetvdb_id
    )

    if show
      showUpdater = ShowUpdater.new(show)
      showUpdater.update
    end
  end
end
