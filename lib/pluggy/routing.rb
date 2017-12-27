require 'mustermann'

require 'pluggy/routing/asset'
require 'pluggy/routing/block'
require 'pluggy/routing/controller'

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

      OPT_TO_TYPE = {
        block: Route::Block,
        asset: Route::Asset,
        to: Route::Controller
      }.freeze

      def initialize(verb, uri, mime_type: nil, **opts, &block)
        @verb = format_verb(verb)
        @uri = format_uri(uri)
        @pattern = Mustermann.new(@uri)
        opts = opts.merge(block: block)
        action_class, value = parse_opts(opts)
        @action = action_class.new(value, mime_type: mime_type)
      end

      def evaluate_with(env, req = nil)
        req ||= Rack::Request.new(env)
        request_params = req.params.symbolize_keys
        params = request_params.merge(path_params(req.path))
        @action.evaluate(env, req, params)
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

      def parse_opts(opts)
        opt = opts.select { |k, v| OPT_TO_TYPE.keys.include?(k) && !v.nil? }
        error = 'No action, asset or block passed'
        throw error unless opt.length == 1
        key, value = opt.flatten
        # [action_class, value]
        [OPT_TO_TYPE[key], value]
      end

      def format_uri(uri)
        uri.to_s
      end

      def format_verb(verb)
        verb.downcase.to_sym
      end

      def path_params(path)
        path_matches = @pattern.match(path)
        path_matches.names.zip(path_matches.captures).symbolize_keys
      end
    end
  end
end
