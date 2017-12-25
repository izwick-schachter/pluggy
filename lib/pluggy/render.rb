module Pluggy
  class View
    attr_reader :content, :metadata
    
    def initialize(content = nil, mime_type: nil, filename: '')
      content = content.content while content.is_a?(View)
      @content = content
      filename = File.basename filename
      @metadata = {
        mime_type: mime_type || (filename.empty? ? 'text/html' : Rack::Mime.mime_type(".#{filename.split('.')[1]}")),
        filename: filename
      }
    end
  end
end
