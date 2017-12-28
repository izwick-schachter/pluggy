module Pluggy
  class Router
    class Route
      class Block < Action
        def initialize(block, mime_type: 'text/html', **opts)
          super(**opts)
          @block = block
          @mime_type = mime_type
        end

        def evaluate(_env, req, params)
          result = @block.call(params, req)
          @view_class.new(result, mime_type: @mime_type)
        end
      end
    end
  end
end
