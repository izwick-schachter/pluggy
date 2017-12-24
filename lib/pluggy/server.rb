require "rack"
require "webrick"

module Pluggy
  class Server
    def initialize(router)
      @router = router
    end

    def call(env)
      puts "Getting for #{env['PATH_INFO']}##{env['REQUEST_METHOD'].downcase.to_sym}"
      route = @router.find_by(uri: env['PATH_INFO'], verb: env['REQUEST_METHOD'], mustermann: true)
      return status 404 if route.nil?
      result = route.evaluate_with(env)
      view = result.is_a?(View) ? result : View.new(result)
      rval = [view.content ? 200 : 404, headers(view), [view.content.to_s]]
      puts "Returning #{rval}"
      rval
    end

    private

    def headers(r)
      {"Content-Type" => r.metadata[:mime_type]}
    end

    def status(status_code)
      [status_code, {}, ["Status #{status_code}"]]
    end
  end
end