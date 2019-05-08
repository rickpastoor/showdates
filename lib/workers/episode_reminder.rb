# frozen_string_literal: true

require 'sidekiq'

class EpisodeReminderWorker
  include Sidekiq::Worker

  def perform(user_id)
  end
end
