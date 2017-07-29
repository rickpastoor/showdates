require 'dotenv'
Dotenv.load

require 'rack'

require_relative 'lib/setup'
require_relative 'lib/models'

require_relative 'lib/workers/update_show.rb'
require_relative 'lib/showupdater.rb'

Encoding.default_external = Encoding::UTF_8
