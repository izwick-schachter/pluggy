module Pluggy
  class Router
    class Route
      # A template class which all the ActionClasses are derived from. It
      # provides error handling for settings and view_class, as well as
      # helper methods.
      #
      # @see The Action Class spec
      class Action
        # Validates and creates @settings and @view_class for the ActionClass
        def initialize(arg, settings: nil, view_class: nil, **_opts)
          warn 'No settings given' if settings.nil?
          throw 'No view class given' if view_class.nil?
          @settings = settings || Pluggy::Settings.new
          @view_class = view_class
          throw "Invalid #{self}" unless self.class.valid?(arg, settings: @settings)
        end

        private

        def path(*args)
          File.join(@settings[:root], *args)
        end
      end
    end
  end
end
