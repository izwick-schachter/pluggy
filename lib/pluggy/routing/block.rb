module Pluggy
  class Router
    class Route
      class Block
        def initialize(block, mime_type: 'text/html', settings: Pluggy::Settings.new)
          warn "You didn't pass any settings" if settings.nil?
          @settings = settings
          @block = block
          @mime_type = mime_type
        end

        def evaluate(_env, req, params)
          result = @block.call(params, req)
          View.new(result, mime_type: @mime_type)
        end
      end
    end
  end
end
