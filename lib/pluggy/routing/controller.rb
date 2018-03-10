module Pluggy
  class Router
    class Route
      class Controller < Action
        using ConvenienceRefinements

        def initialize(target, mime_type: 'text/html', **opts)
          super(**opts)
          @mime_type = mime_type
          controller, @action_name = target.split('#')
          @controller_name = controller_name_from(controller)
          load_controller @controller_name
          controller_action_from(@controller_name, @action_name)
        end

        def evaluate(env, req, params)
          controller_vars(params: params, env: env, req: req)
          view_files = File.join(view_dir, @controller_name, @action_name.to_s)
          view_file = Dir["#{view_files}*"][0]
          warn "Could not find view file with pattern #{view_files}. Rendering empty view." if view_file.nil?
          result = @action.call
          view = @view_class.new(result, filename: view_file.to_s, mime_type: @mime_type, settings: @settings)
          view.compile(@controller.instance_exec { binding })
        end

        def self.enabled?(settings)
          Dir.exist?(File.join(settings[:root], settings[:view_path])) &&
            Dir.exist?(File.join(settings[:root], settings[:controller_path]))
        end

        private

        def controller_name_from(controller)
          controller.underscore.gsub(/#{controller_suffix}$/, '')
        end

        def load_controller(controller_name)
          controller_file_basename = "#{controller_name}#{controller_suffix}.rb"
          file = File.join(controller_dir, controller_file_basename)
          if File.exist? file
            load file
          else
            warn "Controller at #{file} does not exist"
          end
        end

        def controller_action_from(controller, action)
          controller = controller.titleize
          controller += 'Controller' unless Object.const_defined?(controller)
          @controller = Object.const_get(controller).new
          @action = @controller.method(action)
        end

        def controller_vars(**opts)
          opts.each do |k, v|
            setter = "#{k}=".to_sym
            @controller.method(setter).call(v) if @controller.respond_to? setter
          end
        end

        # Aliases for settings

        def controller_suffix
          @settings[:controller_suffix]
        end

        def view_dir
          path(@settings[:view_path])
        end

        def controller_dir
          path(@settings[:controller_path])
        end
      end
    end
  end
end
