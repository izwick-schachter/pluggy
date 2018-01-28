module Pluggy
  class Router
    class Route
      class Asset < Action
        def initialize(filename, block: nil, **opts)
          super(**opts)
          @file = File.new(Dir["#{File.join(asset_dir, filename)}*"][0])
          @block = block
        end

        def evaluate(env, req, params)
          scope = Class.new
          scope.send(:define_method, :params) { params }
          scope.send(:define_method, :req) { req }
          scope.send(:define_method, :env) { env }
          inst = scope.new
          inst.instance_exec(&@block) unless @block.nil?
          b = inst.instance_exec { binding }
          @view_class.new(@file.read, filename: @file.to_path, settings: @settings).compile(b)
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
