require 'pluggy/view'

module Pluggy
  # {include:file:specs/Router.md}
  #
  # @note Here's an interesting thing about Matchers -- by default they use
  #   the Router's matcher_class, but sometimes they can have a custom matcher.
  #   Checking if a Route is matched is up to the Route, **not** the router. A
  #   router _could_ steal that power by checking the Route itself and checking
  #   matches there, but then it'd have to manipulate req and env to insert the
  #   path params in.
  class Router
    # An array of routes that the {Router} will route to.
    attr_reader :routes
    attr_accessor :settings

    # Creates a new router, either with no routes or with an array of routes
    # that are passed to it.
    #
    # @spec
    # @param [Array<Route>] routes The routes to create the {Router} from.
    def initialize(routes = [], route_class: Route, matcher_class: nil, view_class: Pluggy::View, settings: nil)
      warn 'You did not pass a matcher' if matcher_class.nil?
      warn 'You did not pass any settings' if settings.nil?
      @settings = settings || Pluggy::Settings.new
      @view_class = view_class
      @routes = routes
      @route_class = route_class
      @matcher_class = matcher_class
    end

    # Creates a route that the router will track. These routes will then be
    # searched in {where} and {find_by}.
    #
    # @see The documentation for {Route#initialize}, because arguments to
    #   this method are passed directly to {Route#initialize}.
    #
    # @spec
    def route(*args, **opts, &block)
      opts = { view_class: @view_class,
               matcher_class: @matcher_class,
               settings: @settings }.merge(opts)
      route = @route_class.new(*args, **opts, &block)
      @routes.push route
      route
    end

    # The router seaches through its routes based on the options passed to this
    # method.
    #
    # @spec
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
    # @spec
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

    class Routable
      def initialize(verb, uri, matcher_class: nil, settings: nil, **_opts)
        warn "You didn't pass any settings" if settings.nil?
        @settings = settings || Pluggy::Settings.new
        @verb = format_verb(verb)
        @uri = format_uri(uri)
        @pattern = matcher_class.new(@uri) if matcher_class.respond_to? :new
      end

      # A helper method for {#matches?}. It returns true when URI is nil to
      # play nice with {#matches?}. If no matcher is provided, it will look
      # for an exact match, otherwise it will try to use the matcher.
      #
      # @param [#to_s] uri The URI to check against the current route.
      def matches_uri?(uri, **_opts)
        return true if uri.nil?
        return @uri == format_uri(uri) unless @pattern.respond_to? :match
        @pattern.match(format_uri(uri))
      end

      # A helper method for {#matches?}. It returns true when verb is nil
      # to play nice with {#matches?}. It simply checks for a (formatted)
      # exact match.
      def matches_verb?(verb = nil, **_opts)
        return true if verb.nil?
        format_verb(verb) == @verb
      end

      # @spec
      def matches?(uri: nil, verb: nil, **opts)
        return false if uri.nil? && verb.nil?
        matches_uri?(uri, **opts) && matches_verb?(verb, **opts)
      end

      private

      def format_uri(uri)
        uri.to_s
      end

      def format_verb(verb)
        verb.downcase.to_sym
      end
    end

    # {include:file:specs/Route.md}
    class Route < Routable
      using ConvenienceRefinements

      # This is ugly, but if these move to the top of the file, you'll get
      # a superclass mismatch because Route gets created extending Object,
      # and you're trying to make it extend Routable here.

      require 'pluggy/actions/asset'
      require 'pluggy/actions/block'
      require 'pluggy/actions/controller'
      require 'pluggy/actions/text'

      attr_reader :verb, :uri, :action, :pattern

      # An array which maps route types to their corresponding classes.
      # @todo Possibly this should be delegated to {Router}
      OPT_TO_TYPE = [
        [:asset, Route::Asset],
        [:block, Route::Block],
        [:to, Route::Controller],
        [:text, Route::Text]
      ].freeze

      # @spec
      #
      # @param [#to_sym] verb The HTTP verb the route should respond to.
      # @param [#to_s] uri The URI the route should respond to.
      # @param matcher_class A matcher class which follows the matcher class
      #   spec. By default, Mustermann.
      # @param view_class A view class which follows the view class spec. By
      #   default, the {Pluggy::View} class.
      # @param [Pluggy::Settings] settings The settings to run the route under.
      def initialize(verb, uri, asset = nil, **opts, &block)
        warn 'No settings passed' if opts[:settings].nil?
        @settings = opts[:settings] || Settings.new
        Route::Asset.valid?(asset, settings: @settings) ? opts[:asset] = asset : opts[:text] = asset
        super(verb, uri, **opts)
        @view_class = opts[:view_class]
        opts[:block] = block
        action_class, value = parse_opts(opts)
        warn "#{action_class} disabled" unless action_class.enabled?(@settings)
        @action = action_class.new(value, mime_type: opts[:mime_type],
                                          view_class: @view_class,
                                          settings: @settings, **opts)
      end

      # @spec
      #
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

      private

      def parse_opts(opts)
        opt = OPT_TO_TYPE.select { |k, _v| opts.keys.include?(k) && !opts[k].nil? }
        error = 'No action, asset or block passed'
        throw error unless opt.length >= 1
        warn 'More than one action class matched' if opt.length > 1
        key, action_class = opt[0]
        # [action_class, value]
        [action_class, opts[key]]
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
