require 'pluggy/version'
require 'pluggy/convenience_refinements'

require 'pluggy/render'

require 'pluggy/routing'
require 'pluggy/server'
require 'pluggy/compiler'
require 'pluggy/controller'

require 'pluggy/initializers'

module Pluggy
  ROUTER = Router.new
end

def route(*args, **opts, &block)
  Pluggy::ROUTER.route(*args, **opts, &block)
end

def get(*args, **opts, &block)
  route(:get, *args, **opts, &block)
end

def start
  Rack::Server.start(
    app: Pluggy::Server.new(Pluggy::ROUTER),
    server: WEBrick,
    port: 3150
  )
end

def to_compile(ext, &block)
  Pluggy::Compiler.new(ext.to_sym, &block)
end

to_compile :erb do |t, b|
  ERB.new(t).result(b)
end

at_exit { start }
