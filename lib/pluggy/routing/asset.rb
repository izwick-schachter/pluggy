module Pluggy
  class Router
    class Route
      class Asset
        def initialize(filename, **_opts)
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
          File.join(Pluggy.settings[:root], Pluggy.settings[:asset_path])
        end
      end
    end
  end
end
