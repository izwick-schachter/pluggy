module Pluggy
  class Router
    class Route
      class Block < Action
        def initialize(block, mime_type: 'text/html', **opts)
          super(**opts)
          @block = block
          @mime_type = mime_type
        end

        def self.enabled?(_settings)
          true
        end

        def evaluate(_env, req, params)
          result = @block.call(params, req)
          @view_class.new(result, mime_type: @mime_type, settings: @settings)
        end
      end
    end
  end
end
