# frozen_string_literal: true

require 'sidekiq'
require 'mailer'
require 'helpers/email_template'

class EpisodeReminderWorker
  include Sidekiq::Worker

  def perform(user_id)
    @user = SDUser[user_id]

    return unless @user

    episodeBuilder = EpisodeBuilder.new(@user)
    episodes_airing_today = episodeBuilder.build_airingtoday

    return if episodes_airing_today.count.zero?

    mailer = Mailer.new
    mailer.send_mail(
      recipient_email: @user.emailaddress,
      subject: 'New episodes airing!',
      html: EmailTemplate.apply_layout(nil, 'episode_reminder',
        'base_url' => ENV['BASE_URL'],
        'emailaddress' => @user.emailaddress,
        'heading' => heading(@user.firstname))
    )
  end

  def heading(firstname)
    [
      "Hey there, #{firstname}!",
			"How are you doing today, #{firstname}?",
			"Got great news for you, #{firstname}!",
			"#{firstname}, what's up?",
			"Ol&aacute; #{firstname}!",
			"Aloha #{firstname}!"
    ].sample
  end
end
