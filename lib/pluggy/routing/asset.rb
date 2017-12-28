module Pluggy
  class Router
    class Route
      class Asset
        def initialize(filename, settings: Pluggy::Settings.new, **_opts)
          warn "You didn't pass any settings" if settings.nil?
          @settings = settings
          @filename = filename
        end

        def evaluate(env, req, params)
          file = File.new(File.join(asset_dir, @filename))
          scope = Class.new
          scope.send(:define_method, :params) { params }
          scope.send(:define_method, :req) { req }
          scope.send(:define_method, :env) { env }
          b = scope.new.instance_exec { binding }
          View.new(file.read, filename: file.to_path).compile(b)
        end

        private

        def asset_dir
          File.join(@settings[:root], @settings[:asset_path])
        end
      end
    end
  end
end
