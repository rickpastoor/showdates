# frozen_string_literal: true

Given("episode reminders are sent") do
  episode_reminder = EpisodeReminderMailer.new
  episode_reminder.mail_progress
end
