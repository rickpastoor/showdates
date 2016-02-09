require 'sidekiq'

class ShowWorker
  include Sidekiq::Worker

  def perform(thetvdb_id, updatedat)
    # Magic!
  end
end
