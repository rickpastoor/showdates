# frozen_string_literal: true

require 'simplecov'

TEST_DIR = __dir__
SRC_DIR = File.expand_path('../../lib', TEST_DIR)
$LOAD_PATH.unshift SRC_DIR

ENV['RACK_ENV'] = 'test'

require 'dotenv'
Dotenv.load

require 'cucumber/rspec/doubles'
require 'sequel'
require 'rack/test'
require 'cucumber/timecop'

require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

require 'setup'

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations')

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

require 'episode_reminder_mailer'

# Set up sidekiq testing
require 'sidekiq/testing'
Sidekiq::Testing.inline!

require_relative '../../app.rb'
