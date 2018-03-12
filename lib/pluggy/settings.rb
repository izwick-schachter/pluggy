module Pluggy
  class Settings
    attr_reader :settings

    class Setting
      attr_reader :name, :validation, :value, :locked

      def initialize(setting_a = nil, locked: false, **setting_h, &validation)
        # This workaround exists becuase the setting will eat locked if passed as setting: value
        setting = (setting_a || setting_h).to_a[0]
        @name = setting[0]
        @value = setting[1]
        @locked = locked
        @value.freeze if @locked
        @initial_value = value.freeze
        @validation = block_given? ? validation : proc { true }
      end

      def value=(new_val)
        warn "The #{@name} setting has been locked. It will not be changed." if @locked
        @value = new_val if !@locked && @validation.call(new_val)
      end

      def reset
        @value = @initial_value
      end

      def method_missing(method_name, *args, &block)
        @value.respond_to?(method_name) ? @value.method(method_name).call(*args, &block) : super
      end

      def respond_to_missing?(method_name, *args, &block)
        @value.respond_to?(method_name) || super
      end
    end

    def defaults
      [
        { compilers: Compiler::Collection.new },
        { http_verbs: %i[get post put patch delete].freeze },
        { root: Dir.pwd, locked: true },
        { view_path: 'views' },
        { controller_path: 'controllers' },
        { asset_path: 'assets' },
        { controller_suffix: '_controller' },
        { default_mime_type: 'text/html' },
        { hooks: Hooks.new }
      ].map { |s| Setting.new(s) }
    end

    def initialize(settings = [])
      settings = [settings] unless settings.respond_to?(:each) && !settings.is_a?(Setting)
      invalid_settings = 'Invalid settings passed'
      throw invalid_settings unless settings.all? { |s| s.is_a? Setting }
      @settings = settings + defaults.reject do |setting|
        settings.map(&:name).include?(setting.name)
      end
    end

    def reset
      @settings.map(&:reset)
    end

    def keys
      @settings.map(&:name)
    end

    def values
      @settings.map(&:value)
    end

    def [](name)
      get(name)
    end

    def get_setting(name)
      @settings.select { |s| s.name == name }[0]
    end

    def get(name)
      get_setting(name).value
    end

    def []=(name, value)
      set(name, value)
    end

    def set(name, value)
      get_setting(name).value = value
    end

    def enable(name)
      set(name, true)
    end

    def disable(name)
      set(name, false)
    end
  end
end
