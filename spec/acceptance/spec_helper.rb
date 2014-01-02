# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'ashikawa-core'

port = ENV.fetch('ARANGODB_PORT', 8529)
username = ENV.fetch('ARANGODB_USERNAME', 'root')
password = ENV.fetch('ARANGODB_PASSWORD', '')
disable_authentication = ENV.fetch('ARANGODB_DISABLE_AUTHENTIFICATION', 'true')

# The database instance to use for all specs
DATABASE = Ashikawa::Core::Database.new do |config|
  config.url = "http://localhost:#{port}"

  unless disable_authentication == 'true'
    config.username = username
    config.password = password
  end
end
