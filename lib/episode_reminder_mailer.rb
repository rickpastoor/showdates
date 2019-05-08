# frozen_string_literal: true

require 'workers/episode_reminder'

# Class figures out who to check new episodes for
class EpisodeReminderMailer
  def mail_progress
    users = SDUser.where(sendemailnotice: 'yes').exclude(emailaddress: nil)

    users.each do |user|
      EpisodeReminderWorker.perform_async(user.id)
    end
  end
end
