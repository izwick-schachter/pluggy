require 'mustermann'
require 'webrick'
require 'faye/websocket'

module Pluggy
  class App
    attr_accessor :server, :router, :settings, :wsstack_collection

    # rubocop:disable Metrics/ParameterLists
    def initialize(server: Pluggy::Server, router: Pluggy::Router,
                   route: Pluggy::Router::Route, view: Pluggy::View,
                   matcher: Mustermann, settings: [])
      # rubocop:enable Metrics/ParameterLists
      @settings = Pluggy::Settings.new(settings)
      @compilers = @settings[:compilers]
      @router = router.new(route_class: route, matcher_class: matcher, view_class: view, settings: @settings)
      @server = server

      configure_websockets
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

    def ws(*args)
      @wsstack_collection.ws(*args)
    end

    private

    def configure_websockets
      @wsstack_collection = WSStackCollection.new
      Hook.register to: :request_start do |env|
        next unless Faye::WebSocket.websocket?(env)
        req = Rack::Request.new(env)
        ws = Faye::WebSocket.new(env)
        @wsstack_collection.select { |wsstack| wsstack.matches?(uri: req.path) }.each do |wsstack|
          wsstack.defaults.each do |event, block|
            ws.on(event) { |e| block.call(e, ws) }
          end
          wsstack.push(ws)
        end
        ws.rack_response
      end
    end
  end
end
