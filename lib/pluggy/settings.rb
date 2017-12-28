module Pluggy
  class Settings
    using ConvenienceRefinements

    def defaults
      {
        compilers: CompilerCollection.new,
        http_verbs: %i[get post put patch delete].freeze,
        view_path: check_filepath('views').freeze,
        controller_path: check_filepath('controllers').freeze,
        asset_path: check_filepath('assets').freeze,
        controller_suffix: '_controller'.freeze,
        default_mime_type: 'text/html'.freeze,
        root: root
      }
    end

    VALIDATIONS = {
      root: proc { |root|
        Dir.exist? root
      }.freeze,
      view_path: proc { |views|
        views.nil? || Dir.exist?(File.join(get(:root), views))
      }.freeze,
      controller_path: proc { |controllers|
        controllers.nil? || Dir.exist?(File.join(get(:root), controllers))
      }.freeze,
      asset_path: proc { |assets|
        assets.nil? || Dir.exist?(File.join(get(:root), assets))
      }.freeze
    }.freeze

    def initialize(settings = {}, validations = VALIDATIONS.dup)
      settings = defaults.merge(settings)
      @settings = Hash(settings)
      @validations = Hash(validations)
      @settings.each { |k, v| validate(k, v) }
    end

    def enable(setting)
      validate(setting, true)
      @settings[setting] = true
    end

    def disable(setting)
      validate(setting, false)
      @settings[setting] = false
    end

    def set(key, value)
      validate(key, value)
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
      warning = "Tried to access uninitialized setting #{key}"
      warn warning unless @settings.keys.include? key
      @settings[key]
    end

    def []=(key, value)
      validate(key, value)
      @settings[key] = value
    end

    private

    def validate(setting, value)
      error = "Invalid value #{value} for #{setting}"
      # Should be valid if validation doesn't exist
      validation = @validations[setting] || proc { true }
      throw error unless instance_exec(value, &validation)
    end

    def root
      Dir.pwd.freeze
    end

    def check_filepath(path, name: nil)
      warning = "#{name || path.to_s.titleize} pulling functionality with " \
                "not work as defined due to the #{path} directory not existing."
      file_exists = File.exist? File.join(root, path)
      warn warning unless file_exists
      file_exists ? path : nil
    end
  end

  def self.settings
    @settings ||= Settings.new
  end
end
