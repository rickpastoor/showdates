# frozen_string_literal: true

require 'dotenv'
Dotenv.load

ROOT_DIR = File.expand_path('./lib', __dir__)
$LOAD_PATH.unshift ROOT_DIR

require 'rack'

require 'setup'
require 'models'

Dir.glob('./lib/workers/*.rb').each { |file| require file }

Encoding.default_external = Encoding::UTF_8
