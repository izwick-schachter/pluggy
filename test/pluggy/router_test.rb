require 'test_helper'
require 'rack/test'

class RouterTest < MiniTest::Test
  def setup
    @router = Pluggy::Router.new(matcher_class: Mustermann)
  end

  %i[get post put patch delete].each do |verb|
    define_method(verb) do |*args, **opts, &block|
      @router.route(verb, *args, **opts, &block)
    end
  end

  def test_route_creation
    route = @router.route(:get, '/a', 'test')
    assert_instance_of Pluggy::Router::Route, route
  end

  def test_geting_routes
    foo = @router.route(:get, '/b', 'foo')
    bar = @router.route(:get, '/b', 'bar')
    assert_equal 'foo', @router.find_by(uri: '/b').evaluate_with(mock_request.env, mock_request).content
    assert_equal foo, @router.where(uri: '/b')[0]
    assert_equal bar, @router.where(uri: '/b')[1]
  end
end
