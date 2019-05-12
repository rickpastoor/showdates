# frozen_string_literal: true

require 'launchy'

class TestMailer
  def initialize(emails)
    @emails = emails
  end

  def send_message(message, _async = true)
    @emails.push(message)

    if ENV['PREVIEW_MAILS']
      file = File.open("/tmp/message-#{('a'..'z').to_a.sample(8).join}.html", 'w')
      file.write(message[:html])
      file.flush
      Launchy.open(file.path)
    end
  end
end

And /^an empty mailbox$/ do
  @emails = []
  allow_any_instance_of(MailTransportFactory).to receive(:create_transporter).and_return(TestMailer.new(@emails))
end

Then /^there should be (\d+) emails sent$/ do |expected_number_of_emails|
  @emails ||= []
  @emails.count.must_equal(expected_number_of_emails.to_i)
end

And /^the subject of the( | first | second )email should be "(.+)"$/ do |position, subject|
  position = position.strip

  email_position = 0
  email_position = 1 if position == 'second'

  @emails[email_position][:subject].must_equal(subject)
end

And /^the content of the( | first | second )email should contain "(.+)"$/ do |position, string|
  position = position.strip

  email_position = 0
  email_position = 1 if position == 'second'

  @emails[email_position][:html].include?(string).must_equal true
end

Then("the link of the email containing {string} is clicked") do |string|
  position = 0

  email_position = 0
  email_position = 1 if position == 'second'

  matches = /href\s*=\s*"([^"]*)"/.match(@emails[email_position][:html])

  matches.wont_be_nil

  visit matches[1].gsub(ENV['BASE_URL'], '/')
end
