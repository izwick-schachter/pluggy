module Pluggy
  class View
    attr_reader :content, :mime_type, :filename

    def initialize(content = nil, mime_type: nil, filename: '')
      content = content.content while content.is_a?(View)
      @content = content
      @file = File.new(filename) if File.exist? filename
      @filename = File.basename filename
      ext = @filename.split('.')[1]
      ext_mime_type = Rack::Mime.mime_type(".#{ext}")
      default = Pluggy.settings[:default_mime_type]
      @mime_type = mime_type || (@filename.empty? ? default : ext_mime_type)
    end

    def compile(b = TOPLEVEL_BINDING)
      @content = Compiler.compile(@file, b) unless @file.nil?
      self
    end

    def metadata
      warn 'Using View#metadata is deprecated. ' \
           'Please use either View#mime_type or View#filename'
      {
        mime_type: @mime_type,
        filename: @filename
      }
    end
  end
end
