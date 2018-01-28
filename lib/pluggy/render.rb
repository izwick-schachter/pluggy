module Pluggy
  class View
    attr_reader :content, :mime_type

    # @spec
    # @todo Document/Refactor
    def initialize(content = nil, mime_type: nil, settings: nil, filename: '')
      warn 'No settings passed' if settings.nil?
      content = content.content while content.is_a?(View)
      @content = content
      @settings = settings
      @file = File.new(filename) if File.exist? filename
      @filename = File.basename filename
      ext = @filename.split('.').last
      ext_mime_type = Rack::Mime.mime_type(".#{ext}")
      default = @settings[:default_mime_type]
      @mime_type = mime_type || (@filename.empty? ? default : ext_mime_type)
    end

    # @spec
    def compile(b = TOPLEVEL_BINDING)
      @content = @settings[:compilers].compile(@file, b) unless @file.nil?
      self
    end
  end
end
