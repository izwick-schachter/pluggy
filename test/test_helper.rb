$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'pluggy'

$VERBOSE = nil # Hide warnings

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/reporters'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

def mock_request
  Rack::Request.new(Rack::MockRequest.env_for('http://example.com:8080/', 'REMOTE_ADDR' => '10.10.10.10'))
end
