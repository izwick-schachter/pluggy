require 'pluggy/version'
require 'pluggy/app'

# This file just defines some shortcuts. To live without them
# you can require 'pluggy/app'

# APP as the master app

APP = Pluggy::App.new

# Define HTTP verb methods

def route(*args, **opts, &block)
  APP.route(*args, **opts, &block)
end

%i[get post put patch delete].each do |verb|
  define_method(verb) do |*args, **opts, &block|
    route(verb, *args, **opts, &block)
  end
end

# Websockets

def ws(*args)
  APP.ws(*args)
end

# Make files easier

def alias_file(target, source)
  get(target, asset: source)
end

# Define easy use compiler methods

def to_compile(ext, &block)
  APP.to_compile(ext.to_sym, &block)
end

to_compile :erb do |t, b|
  ERB.new(t).result(b)
end
