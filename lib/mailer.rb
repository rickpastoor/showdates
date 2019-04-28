# frozen_string_literal: true

require_relative './workers/email'

# This transporter sends emails via Amazon SES
class SESTransporter
  def send_message(message, async = true)
    if async
      EmailWorker.perform_async(message)
      return true
    end

    ses = AWS::SES::Base.new(
      access_key_id: ENV['SES_ACCESS_KEY'],
      secret_access_key: ENV['SES_SECRET_KEY'],
      server: ENV['SES_SERVER']
    )

    ses.send_email(
      to: message[:to],
      bcc: message[:bcc],
      source: message[:source],
      subject: message[:subject],
      html_body: message[:html]
    )
  end
end

# This factory creates transporters, defauls to SESTransporter
class MailTransportFactory
  def create_transporter
    SESTransporter.new
  end
end

# The mailer composes email objects to be send
class Mailer
  def initialize(transport_factory = nil)
    transport_factory ||= MailTransportFactory.new
    @m = transport_factory.create_transporter
  end

  def send_mail(recipient_email:, html:, subject:, headers: nil, async: true, bcc: nil)
    # Check if html content is passed
    raise ArgumentError, 'html should not be nil' if html.nil?

    # Create message object
    message = {
      source: '"Showdates" <hi@showdates.me>',
      to: recipient_email,
      subject: subject,
      html: html
    }

    message[:bcc] = bcc if bcc

    message[:headers] = headers if headers

    @m.send_message(message, async)
  end
end
