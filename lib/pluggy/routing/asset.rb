module Pluggy
  class Router
    class Route
      class Asset < Action
        def initialize(filename, **opts)
          super(**opts)
          @filename = filename
        end

        def evaluate(env, req, params)
          file = File.new(File.join(asset_dir, @filename))
          scope = Class.new
          scope.send(:define_method, :params) { params }
          scope.send(:define_method, :req) { req }
          scope.send(:define_method, :env) { env }
          b = scope.new.instance_exec { binding }
          @view_class.new(file.read, filename: file.to_path, settings: @settings).compile(b)
        end

        def self.enabled?(settings)
          Dir.exist? File.join(settings[:root], settings[:asset_path])
        end

        private

        def asset_dir
          path(@settings[:asset_path])
        end
      end
    end
  end
end
