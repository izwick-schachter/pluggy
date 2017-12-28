require 'mustermann'

require 'pluggy/routing/asset'
require 'pluggy/routing/block'
require 'pluggy/routing/controller'

module Pluggy
  # {include:file:specs/Router.md}
  class Router
    # An array of routes that the {Router} will route to.
    attr_reader :routes

    # Creates a new router, either with no routes or with an array of routes
    # that are passed to it.
    #
    # @note This is part of the specification for {Router}s.
    #
    #   {include:file:specs/Router/#initialize/requirements.md}
    #
    # @param [Array<Route>] routes The routes to creation the {Router} from.
    def initialize(routes = [])
      @routes = routes
    end

    # Creates a route that they track. These routes will then be searched in
    # {where} and {find_by}.
    #
    # @note This is part of the specification for {Router}s.
    #
    #   {include:file:specs/Router/#route/requirements.md}
    #
    # @param [Symbol] verb The HTTP verb that the route should respond to.
    #   This can also be anything else that the router will parse.
    # @param [String] uri The uri that should be reponded to. This can also
    #   be a pattern, or anything else that the router will parse.
    def route(verb, uri, *args, &block)
      @routes.push Route.new(verb, uri, *args, &block)
    end

    # The router seaches through its routes based on the options passed to this
    # method.
    #
    # @note This is part of the specification for {Router}s.
    #
    #   {include:file:specs/Router/#where/requirements.md}
    #
    # @param [#to_s] uri The uri that you're trying to match.
    # @param [#to_sym] verb The verb you're trying to match.
    # @param opts The options (e.g. mustermann: true)
    # @return [Array<Route>]
    def where(uri: nil, verb: nil, **opts)
      verb = verb.downcase.to_sym unless verb.nil?
      uri = uri.to_s unless uri.nil?
      @routes.select do |route|
        route.matches(uri: uri, verb: verb, **opts)
      end
    end

    # Similar to {#where}, but only returns one route. This is the method where
    # the {Router} deals with precedence of different routes.
    #
    # @note This is part of the specification for {Router}s.
    #
    #   {include:file:specs/Router/#find_by/requirements.md}
    #
    # @param [#to_s] uri The uri that you're trying to match.
    # @param [#to_sym] verb The verb you're trying to match.
    # @param opts The options (e.g. mustermann: true)
    # @return [Route]
    def find_by(uri: nil, verb: nil, **opts)
      where(uri: uri, verb: verb, **opts).first
    end

    class Route
      using ConvenienceRefinements

      attr_reader :verb, :uri, :action, :pattern

      # An array which maps route types to their corresponding classes.
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
