require 'rack'

module Pluggy
  class Server
    def initialize(router, settings: Pluggy::Settings.new)
      warn "You didn't pass any settings" if settings.nil?
      @settings = settings
      @router = router
    end

    # rubocop:disable Metrics/AbcSize
    def call(env)
      req = Rack::Request.new(env)
      puts "Getting for #{req.path}##{req.request_method.downcase.to_sym}"
      route = @router.find_by(
        uri: req.path,
        verb: req.request_method,
        mustermann: true
      )
      return status 404 if route.nil?
      result = route.evaluate_with(env, req)
      view = result.is_a?(View) ? result : View.new(result)
      rval = [view.content ? 200 : 404, headers(view), [view.content.to_s]]
      puts "Returning #{rval}"
      rval
    end
    # rubocop:enable Metrics/AbcSize

    private

    def headers(r)
      { 'Content-Type' => r.mime_type }
    end

    def status(status_code)
      [status_code, {}, ["Status #{status_code}"]]
    end
  end
end
