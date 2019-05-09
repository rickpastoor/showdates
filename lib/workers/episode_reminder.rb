# frozen_string_literal: true

require 'sidekiq'
require 'mailer'
require 'helpers/email_template'

class EpisodeReminderWorker
  include Sidekiq::Worker

  def perform(user_id)
    @user = SDUser[user_id]

    return unless @user

    return if @user.lastemailnotice == @user.local_current_date

    episodeBuilder = EpisodeBuilder.new(@user)
    episodes_airing_today = episodeBuilder.build_airingtoday

    return if episodes_airing_today.count.zero?

    single_episode = (episodes_airing_today.count == 1)

    mailer = Mailer.new
    mailer.send_mail(
      recipient_email: @user.emailaddress,
      subject: single_episode ? '1 new episode airing today' :
        "#{episodes_airing_today.count} new episodes airing today",
      html: EmailTemplate.apply_layout(nil, 'episode_reminder',
        'base_url' => ENV['BASE_URL'],
        'preheader' => preheader(episodes_airing_today),
        'emailaddress' => @user.emailaddress,
        'heading' => heading(@user.firstname),
        'subtitle' => single_episode ? 'Just a heads up: there is one new episode for a show you follow airing today.' :
          "Just a heads up: there are #{episodes_airing_today.count} new episodes for shows you follow airing today.",
        'episodes' => episodes_airing_today)
    )

    @user.lastemailnotice = @user.local_current_date
    @user.save
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

  def preheader(episodes_airing_today)
    if episodes_airing_today.count == 1
      return "#{episodes_airing_today[0]['show_title']} is airing today."
    elsif episodes_airing_today.count == 2
      return "#{episodes_airing_today[0]['show_title']} and #{episodes_airing_today[1]['show_title']} are airing today."
    else
      return "#{episodes_airing_today[0]['show_title']} and #{episodes_airing_today.count - 1} other shows are airing today."
    end
  end
end
