require 'pluggy/actions/action'

module Pluggy
  class Router
    class Route
      class Text < Action
        def initialize(text, block: nil, **opts)
          text = text.to_s
          super(text, **opts)
          @text = text
          @block = block
        end

        def evaluate(_env, _req, _params)
          View.new(@text)
        end

        def self.enabled?(_settings)
          true
        end

        def self.valid?(text, settings: nil)
          text.respond_to? :to_s
        end
      end
    end
  end
end
