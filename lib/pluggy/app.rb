require 'mustermann'
require 'webrick'

module Pluggy
  class App
    attr_accessor :server, :router, :settings

    def initialize(server: Pluggy::Server, router: Pluggy::Router, route: Pluggy::Router::Route, view: Pluggy::View, matcher: Mustermann, settings: {})
      @settings = Pluggy::Settings.new(settings)
      @compilers = @settings[:compilers]
      @router = router.new(route_class: route, matcher_class: matcher, view_class: view, settings: @settings)
      @server = server
    end

    def to_compile(ext, &block)
      @compilers.create(ext.to_sym, &block)
    end

    def start
      Rack::Server.start(
        app: @server.new(@router, settings: @settings),
        server: WEBrick,
        port: 3150
      )
    end

    def route(*args, **opts, &block)
      @router.route(*args, **opts, &block)
    end
  end
end