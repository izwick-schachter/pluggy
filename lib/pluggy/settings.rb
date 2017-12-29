module Pluggy
  class Setting
    attr_reader :name, :validation, :value

    def initialize(setting, locked: false, &validation)
      setting = setting.to_a[0]
      @name = setting[0]
      @value = setting[1]
      @locked = locked
      @value.freeze if @locked
      @initial_value = value.freeze
      @validation = block_given? ? validation : proc { true }
    end

    def value=(new_val)
      warn "The #{@name} setting has been locked" if @locked
      @value = new_val if !@locked && @validation.call(new_val)
    end

    def reset
      @value = @initial_value
    end

    def method_missing(m, *args, &block)
      @value.respond_to?(m) ? @value.method(m).call(*args, &block) : super
    end

    def respond_to_missing?(m, *args, &block)
      @value.respond_to?(m) || super
    end
  end

  class Settings
    attr_reader :settings

    def defaults
      [
        Setting.new(compilers: CompilerCollection.new),
        Setting.new(http_verbs: %i[get post put patch delete].freeze),
        Setting.new(root: Dir.pwd, locked: true),
        Setting.new(view_path: 'views'),
        Setting.new(controller_path: 'controllers'),
        Setting.new(asset_path: 'assets'),
        Setting.new(controller_suffix: '_controller'),
        Setting.new(default_mime_type: 'text/html')
      ]
    end

    def initialize(settings = [])
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
      get(name).value = value
    end

    def enable(name)
      set(name, true)
    end

    def disable(name)
      set(name, false)
    end
  end
end
