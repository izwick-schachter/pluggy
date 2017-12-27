module Pluggy
  class Router
    class Route
      class Controller
        using ConvenienceRefinements

        def initialize(to, mime_type: 'text/html')
          @mime_type = mime_type
          controller, @action_name = to.split('#')
          @controller_name = controller_name_from(controller)
          load_controller @controller_name
          controller_action_from(@controller_name, @action_name)
        end

        def evaluate(env, req, params)
          controller_vars(params: params, env: env, req: req)
          view_files = File.join(view_dir, @controller_name, @action_name.to_s)
          view_file = Dir["#{view_files}*"][0].to_s
          result = @action.call
          view = View.new(result, filename: view_file, mime_type: @mime_type)
          view.compile(@controller.instance_exec { binding })
        end

        private

        def controller_name_from(controller)
          controller.underscore.gsub(/#{controller_suffix}$/, '')
        end

        def load_controller(controller_name)
          controller_file_basename = "#{controller_name}#{controller_suffix}.rb"
          file = File.join(controller_dir, controller_file_basename)
          load file if File.exist? file
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
          Pluggy.settings[:controller_suffix]
        end

        def view_dir
          File.join(Pluggy.settings[:root], Pluggy.settings[:view_path])
        end

        def controller_dir
          File.join(Pluggy.settings[:root], Pluggy.settings[:controller_path])
        end
      end
    end
  end
end
