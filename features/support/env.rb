# frozen_string_literal: true

require 'simplecov'

TEST_DIR = __dir__
SRC_DIR = File.expand_path('../../lib', TEST_DIR)
$LOAD_PATH.unshift SRC_DIR

ENV['RACK_ENV'] = 'test'

require 'dotenv'
Dotenv.load

require 'minitest/spec'
require 'cucumber/rspec/doubles'
require 'sequel'
require 'rack/test'
require 'cucumber/timecop'

MiniTest::Spec.new(nil)

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

Dir.glob('./lib/controllers/*.rb').each { |file| require file }

URL_MAP = Rack::URLMap.new(
  '/' => ShowdatesApp,
  '/about' => AboutController,
  '/account' => AccountController,
  '/api' => ApiController,
  '/couch' => CouchController,
  '/login' => LoginController,
  '/show' => ShowController,
  '/shows' => ShowsController,
  '/episode' => EpisodeController,
  '/settings' => SettingsController,
  '/admin' => AdminController,
  '/feed' => FeedController,
  '/signup' => SignupController
)

module ShowdatesAppWorld
  #include Capybara::DSL
  include Rack::Test::Methods
  include Minitest::Assertions

  def app
    URL_MAP
  end
end

#Capybara.app = URL_MAP

World(MiniTest::Assertions, Rack::Test::Methods, ShowdatesAppWorld)
