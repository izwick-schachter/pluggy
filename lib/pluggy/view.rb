module Pluggy
  class View
    attr_reader :mime_type

    # @spec
    # @todo Document/Refactor
    def initialize(content = nil, mime_type: nil, settings: nil, filename: '')
      warn 'No settings passed' if settings.nil?
      # If a view is passed a view, resurse in
      content = content.content while content.is_a?(View)
      @content = content
      @settings = settings || Settings.new
      @mime_type = mime_type || @settings[:default_mime_type]
      @rand = rand(0...100)
      scan_file(filename) if File.exist? filename
    end

    # @todo Eventually, make this also compile plain old strings with a compiler name passed
    # @spec
    def compile(target_binding = TOPLEVEL_BINDING)
      @content = @settings[:compilers].compile(@file, target_binding) unless @file.nil?
      self
    end

    def content(compiled: true)
      compile if compiled
      # @content will be nil in the case that only a filename is passed
      @content || @file.read
    end

    private

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def scan_file(filename)
      @file = File.new(filename)
      basename = File.basename(@file)
      ext = basename.split('.')[1]
      @mime_type ||= Rack::Mime.mime_type(".#{ext}")
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
