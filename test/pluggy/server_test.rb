require 'test_helper'
require 'rack/test'

class ServerTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    APP.route(:get, '/', 'All responses are OK', headers: { 'Accept-Charset' => 'utf-8' })
    app = APP.rackable
    builder = Rack::Builder.new
    builder.run app
  end

  def test_response_is_ok
    get '/'

    assert last_response.ok?
    assert_equal last_response.body, 'All responses are OK'
  end

  def set_request_headers
    header 'Accept-Charset', 'utf-8'
    get '/'

    assert last_response.ok?
    assert_equal last_response.body, 'All responses are OK'
  end

  # TODO: Test stuff like content-type assumptions, multiple types on one route, etc.
end
