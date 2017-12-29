module Pluggy
  class Router
    class Route
      class Action
        def initialize(settings: Pluggy::Settings.new, view_class: nil, **_opts)
          warn 'No settings given' if settings.nil?
          throw 'No view class given' if view_class.nil?
          @settings = settings
          @view_class = view_class
        end

        private

        def path(*args)
          File.join(@settings[:root], *args)
        end
      end
    end
  end
end
