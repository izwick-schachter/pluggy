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
      resp = Hook.call_hooks :request_start, env
      return resp if valid_resp? resp
      req = Rack::Request.new(env)
      puts "Getting for #{req.path}##{req.request_method.downcase.to_sym}"
      route = @router.find_by(
        uri: req.path,
        verb: req.request_method,
        mustermann: true
      )
      return Hook.call_hooks(:not_found, env) || status(404) if route.nil?
      result = route.evaluate_with(env, req)
      view = result.is_a?(View) ? result : View.new(result)
      resp = [view.content ? 200 : 404, headers(view), [view.content.to_s]]
      mod = Hook.call_hooks(:final_response, resp)
      valid_resp?(mod) ? mod : resp
    end
    # rubocop:enable Metrics/AbcSize

    private

    def headers(r)
      { 'Content-Type' => r.mime_type }
    end

    def status(status_code)
      [status_code, {}, ["Status #{status_code}"]]
    end

    def valid_resp?(resp)
      resp.is_a?(Array) &&
      resp[0].to_s.is_a?(String) &&
      resp[1].is_a?(Hash) &&
      resp[2].respond_to?(:each)
    end
  end
end
