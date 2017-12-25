module Pluggy
  class View
    attr_reader :content, :mime_type, :filename
    
    def initialize(content = nil, mime_type: nil, filename: '')
      content = content.content while content.is_a?(View)
      @content = content
      @filename = File.basename filename
      ext = @filename.split('.')[1]
      @mime_type = mime_type || (@filename.empty? ? 'text/html' : Rack::Mime.mime_type(".#{ext}"))
    end

    def metadata
      warn "Using View#metadata is deprecated. Please use either View#mime_type or View#filename"
      {
        mime_type: @mime_type,
        filename: @filename
      }
    end
  end
end
