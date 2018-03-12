require 'pluggy/actions/action'

module Pluggy
  class Router
    class Route
      class Asset < Action
        def initialize(filename, block: nil, **opts)
          super(filename, **opts)
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
          view = @view_class.new(filename: @file.to_path, settings: @settings)
          view.compile(b)
        end

        def self.enabled?(settings)
          Dir.exist? File.join(settings[:root], settings[:asset_path])
        end

        def self.valid?(filename, settings:)
          asset_dir = File.join(settings[:root], settings[:asset_path])
          Dir["#{File.join(asset_dir, filename.to_s)}*"].length >= 1
        end

        private

        def asset_dir
          path(@settings[:asset_path])
        end
      end
    end
  end
end
