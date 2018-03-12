require 'pluggy/actions/action'

module Pluggy
  class Router
    class Route
      class Block < Action
        def initialize(block = nil, mime_type: 'text/html', **opts, &pblock)
          block ||= pblock
          super(block, **opts)
          @block = block
          @mime_type = mime_type
        end

        def self.enabled?(_settings)
          true
        end

        def self.valid?(block = nil, settings: nil, &pblock)
          block ||= pblock
          block.respond_to? :call
        end

        def evaluate(_env, req, params)
          result = @block.call(params, req)
          @view_class.new(result, mime_type: @mime_type, settings: @settings)
        end
      end
    end
  end
end
