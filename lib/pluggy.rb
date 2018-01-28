require 'pluggy/version'
require 'pluggy/convenience_refinements'

require 'pluggy/hooks'
require 'pluggy/settings'

require 'pluggy/render'

require 'pluggy/routing'
require 'pluggy/server'
require 'pluggy/compiler'
require 'pluggy/controller'

require 'pluggy/initializers'

require 'pluggy/app'

APP = Pluggy::App.new

def route(*args, **opts, &block)
  APP.route(*args, **opts, &block)
end

def get(*args, **opts, &block)
  route(:get, *args, **opts, &block)
end

def to_compile(ext, &block)
  APP.to_compile(ext.to_sym, &block)
end

to_compile :erb do |t, b|
  ERB.new(t).result(b)
end

def alias_file(target, source)
  get(target, asset: source)
end