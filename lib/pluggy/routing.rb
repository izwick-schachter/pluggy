require "mustermann"

module Pluggy
  class Router
    HTTP_VERBS = %i[get post put patch delete]

    attr_reader :routes
    
    def initialize(routes = [])
      @routes = routes
    end

    def route(*args, **opts, &block)
      @routes.push Route.new(*args, **opts, &block)
    end

    def where(uri: nil, verb: nil, **opts)
      verb = verb.downcase.to_sym unless verb.nil?
      uri = uri.to_s unless uri.nil?
      @routes.select do |route|
        route.matches(uri: uri, verb: verb, **opts)
      end
    end

    def find_by(uri: nil, verb: nil, **opts)
      where(uri: uri, verb: verb, **opts).first
    end

    class Route
      using StringRefinements

      attr_reader :verb, :uri, :action, :pattern

      def initialize(verb = :get, uri = "/", to: nil, &block)
        @verb = format_verb(verb)
        @uri = format_uri(uri)
        @pattern = Mustermann.new(uri)
        throw "No action or block passed" if to.nil? && block.nil?
        if to.nil?
          @action = block
        else
          controller, action = to.split('#')
          controller_filename = controller.underscore
          controller_filename += "_controller" unless controller_filename.end_with? "_controller"
          file = File.join(ROOT, '/controllers/', "#{controller_filename}.rb")
          load file if File.exist? file
          controller_action_from(controller, action)
        end
      end

      def evaluate_with(env)
        params = @pattern.match(env['PATH_INFO'])
        if @action.is_a? Proc
          @action.call(params, env)
        elsif @action.is_a? Method
          @controller.params = params if @controller.respond_to? :params=
          @controller.env = env if @controller.respond_to? :env=
          @action.call
        end
      end

      def matches_uri(uri = nil, mustermann: false, **opts)
        return true if uri.nil?
        if mustermann
          format_uri(uri) =~ @pattern
        else
          format_uri(uri) == @uri
        end
      end

      def matches_verb(verb = nil, **opts)
        verb.nil? ? true : format_verb(verb) == @verb
      end

      def matches(uri: nil, verb: nil, **opts)
        return false if format_uri(uri) != @uri && format_verb(verb) != @verb
        matches_uri(uri, **opts) && matches_verb(verb, **opts)
      end

      private

      def format_uri(uri)
        uri.to_s
      end

      def format_verb(verb)
        verb.downcase.to_sym
      end

      def controller_action_from(controller, action)
        controller = controller.titleize
        controller = "#{controller}Controller" unless Object.const_defined?(controller)
        @controller = Object.const_get(controller).new
        @action = @controller.method(action)
      end
    end
  end
end
