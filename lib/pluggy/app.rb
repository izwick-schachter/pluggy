# Internals:

require 'pluggy/version'
require 'pluggy/convenience_refinements'

require 'pluggy/hooks'
require 'pluggy/settings'

require 'pluggy/view'

require 'pluggy/router'
require 'pluggy/server'
require 'pluggy/compiler'

# Bonus packs:

require 'pluggy/websocket'

# Templates:

require 'pluggy/templates/controller'

# Dependencies

require 'mustermann'
require 'webrick'
require 'faye/websocket'

module Pluggy
  class App
    attr_accessor :server, :router, :settings, :wsstack_collection

    # rubocop:disable Metrics/ParameterLists
    def initialize(server: Pluggy::Server, router: Pluggy::Router,
                   route: Pluggy::Router::Route, view: Pluggy::View,
                   matcher: Mustermann, hooks: Pluggy::Hooks.new, settings: [])
      # rubocop:enable Metrics/ParameterLists
      @settings = Pluggy::Settings.new(settings)
      @compilers = @settings[:compilers]
      @router = router.new(route_class: route, matcher_class: matcher, view_class: view, settings: @settings)
      @server = server
      @hooks = hooks

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

    def rackable
      @server.new(@router, settings: @settings)
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
      @hooks.register to: :request_start do |env|
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
