require 'pluggy/routing/action'

require 'pluggy/routing/asset'
require 'pluggy/routing/block'
require 'pluggy/routing/controller'

module Pluggy
  # {include:file:specs/Router.md}
  #
  # Here's an interesting thing about Matchers -- by default they use the
  # Router's matcher_class, but sometimes they can have a custom matcher.
  # Checking if a Route is matched is up to the Route, **not** the router. A
  # router _could_ steal that power by checking the Route itself and checking
  # matches there, but then it'd have to manipulate req and env to insert the
  # path params in.
  class Router
    # An array of routes that the {Router} will route to.
    attr_reader :routes
    attr_accessor :settings

    # Creates a new router, either with no routes or with an array of routes
    # that are passed to it.
    #
    # @note This is part of the specification for {Router}s.
    #
    #   {include:file:specs/Router/#initialize/requirements.md}
    #
    # @param [Array<Route>] routes The routes to creation the {Router} from.
    def initialize(routes = [], route_class: Route, matcher_class: nil, view_class: nil, settings: nil)
      warn 'You did not pass a matcher' if matcher_class.nil?
      warn 'You did not pass any settings' if settings.nil?
      @settings = settings || Pluggy::Settings.new
      @view_class = view_class
      @routes = routes
      @route_class = route_class
      @matcher_class = matcher_class
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
    def route(*args, **opts, &block)
      opts = { view_class: @view_class,
               matcher_class: @matcher_class,
               settings: @settings }.merge(opts)
      @routes.push @route_class.new(*args, **opts, &block)
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
        route.matches?(uri: uri, verb: verb, **opts)
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

    private

    def format_uri(uri)
      uri.to_s
    end

    def format_verb(verb)
      verb.downcase.to_sym
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

      def initialize(verb, uri, matcher_class: nil, view_class: nil, settings: nil, **opts, &block)
        warn "You didn't pass any settings" if settings.nil?
        @settings = settings || Pluggy::Settings.new
        @view_class = view_class
        @verb = format_verb(verb)
        @uri = format_uri(uri)
        @pattern = matcher_class.new(@uri) if matcher_class.respond_to? :new
        opts = opts.merge(block: block)
        action_class, value = parse_opts(opts)
        warn "#{action_class} disabled" unless action_class.enabled?(@settings)
        @action = action_class.new(value, mime_type: opts[:mime_type],
                                          view_class: @view_class,
                                          settings: @settings)
      end

      # Possibly, eventually, there should be a way to insert custom params
      # injected by the router. But currently the only way is to manipulate
      # the request object and inject params there -- and in that case, you
      # can't override the path_params. But the path_params will be {} if
      # @pattern.nil?, so injecting into the Rack::Request will work.
      def evaluate_with(env, req = nil)
        req ||= Rack::Request.new(env)
        request_params = req.params.symbolize_keys
        params = request_params.merge(path_params(req.path))
        @action.evaluate(env, req, params)
      end

      def matches_uri?(uri, **_opts)
        return true if uri.nil?
        return @uri == format_uri(uri) unless @pattern.respond_to? :match
        @pattern.match(format_uri(uri))
      end

      def matches_verb?(verb = nil, **_opts)
        return true if verb.nil?
        format_verb(verb) == @verb
      end

      def matches?(uri: nil, verb: nil, **opts)
        return false if uri.nil? && verb.nil?
        matches_uri?(uri, **opts) && matches_verb?(verb, **opts)
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
        return {} unless @pattern.respond_to? :match
        path_matches = @pattern.match(path)
        return {} if path_matches.nil?
        path_matches.names.zip(path_matches.captures).symbolize_keys
      end
    end
  end
end
