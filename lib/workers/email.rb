# frozen_string_literal: true

require 'sidekiq'

# This worker sends an email
class EmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(message)
    ses = AWS::SES::Base.new(
      access_key_id: ENV['SES_ACCESS_KEY'],
      secret_access_key: ENV['SES_SECRET_KEY'],
      server: ENV['SES_SERVER']
    )

    ses.send_email(
      to: message['to'],
      bcc: message['bcc'],
      source: message['source'],
      subject: message['subject'],
      html_body: message['html']
    )
  end
end
