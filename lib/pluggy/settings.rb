module Pluggy
  class Settings
    DEFAULTS = {
      compilers: {},
      http_verbs: %i[get post put patch delete].freeze,
      view_path: 'views'.freeze,
      controller_path: 'controller'.freeze,
      asset_path: 'assets'.freeze,
      controller_suffix: '_controller'.freeze,
      default_mime_type: 'text/html'.freeze
    }.freeze

    def initialize(settings = DEFAULTS.dup)
      @settings = Hash(settings)
    end

    def enable(setting)
      @settings[setting] = true
    end

    def disable(setting)
      @settings[setting] = true
    end

    def set(key, value)
      @settings[key] = value
    end

    def get(key)
      @settings[key]
    end

    def clear(key)
      @settings.delete(key)
    end

    def reset
      @settings = defaults
    end

    def [](key)
      @settings[key]
    end

    def []=(key, value)
      @settings[key] = value
    end

    def defaults
      DEFAULTS
    end
  end

  def self.settings
    @settings ||= Settings.new
  end
end
