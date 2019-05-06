# frozen_string_literal: true

require 'simplecov'

TEST_DIR = __dir__
SRC_DIR = File.expand_path('../../lib', TEST_DIR)
$LOAD_PATH.unshift SRC_DIR

ENV['RACK_ENV'] = 'test'

require 'dotenv'
Dotenv.load
