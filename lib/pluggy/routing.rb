require 'mustermann'

module Pluggy
  class Router
    attr_reader :routes

    def initialize(routes = [])
      @routes = routes
    end

    def route(*args, &block)
      @routes.push Route.new(*args, &block)
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
      using ConvenienceRefinements

      attr_reader :verb, :uri, :action, :pattern

      def initialize(verb = :get, uri = '/', mime_type: nil, to: nil, &block)
        @mime_type = mime_type
        @verb = format_verb(verb)
        @uri = format_uri(uri)
        @pattern = Mustermann.new(@uri)
        throw 'No action or block passed' if to.nil? && block.nil?
        if to.nil?
          @action = block
        else
          controller, @action_name = to.split('#')
          @controller_name = controller_name_from(controller)
          load_controller @controller_name
          controller_action_from(@controller_name, @action_name)
        end
      end

      def evaluate_with(env, req = nil)
        req ||= Rack::Request.new(env)
        request_params = req.params.symbolize_keys
        params = request_params.merge(path_params(req.path))
        case @action
        when Proc
          evaluate_block_with(env, req, params)
        when Method
          evaluate_action_with(env, req, params)
        end
      end

      def matches_uri(uri = nil, mustermann: false, **_opts)
        return true if uri.nil?
        if mustermann
          format_uri(uri) =~ @pattern
        else
          format_uri(uri) == @uri
        end
      end

      def matches_verb(verb = nil, **_opts)
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
        controller += 'Controller' unless Object.const_defined?(controller)
        @controller = Object.const_get(controller).new
        @action = @controller.method(action)
      end

      def controller_name_from(controller)
        controller.underscore.gsub(/#{controller_suffix}$/, '')
      end

      def load_controller(controller_name)
        controller_file_basename = "#{controller_name}#{controller_suffix}.rb"
        file = File.join(controller_dir, controller_file_basename)
        load file if File.exist? file
      end

      def controller_suffix
        Pluggy.settings[:controller_suffix]
      end

      def evaluate_action_with(env, req, params)
        controller_vars(params: params, env: env, req: req)
        view_files = File.join(view_dir, @controller_name, @action_name.to_s)
        view_file = Dir["#{view_files}*"][0].to_s
        result = @action.call
        view = View.new(result, filename: view_file, mime_type: @mime_type)
        view.compile(@controller.instance_exec { binding })
      end

      def controller_vars(**opts)
        opts.each do |k, v|
          setter = "#{k}=".to_sym
          @controller.method(setter).call(v) if @controller.respond_to? setter
        end
      end

      def evaluate_block_with(_env, req, params)
        result = @action.call(params, req)
        View.new(result, mime_type: @mime_type)
      end

      def view_dir
        File.join(Pluggy.settings[:root], Pluggy.settings[:view_path])
      end

      def controller_dir
        File.join(Pluggy.settings[:root], Pluggy.settings[:controller_path])
      end

      def path_params(path)
        path_matches = @pattern.match(path)
        path_matches.names.zip(path_matches.captures).symbolize_keys
      end
    end
  end
end
