require 'faye/websocket'

module Pluggy
  class WSStackCollection
    include Enumerable

    def initialize(wsstacks = [])
      @wsstacks = Array(wsstacks).flatten
    end

    def ws(*args)
      wsstack = WSStack.new(*args)
      @wsstacks << wsstack
      wsstack
    end

    def each(&block)
      @wsstacks.each(&block)
    end
  end

  class WSStack < Router::Routable
    attr_reader :defaults, :sockets

    def initialize(*args)
      super(*args)
      @sockets = []
      @defaults = []
    end

    def push(websocket)
      @sockets << websocket
    end

    def default_for(event, &block)
      @defaults.push [event.to_sym, block]
    end
  end
end
