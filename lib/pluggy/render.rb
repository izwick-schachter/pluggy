module Pluggy
  class View
    attr_reader :content, :metadata
    
    def initialize(content = nil, mime_type: "text/html", filename: nil)
      @content = content
      @metadata = {
        mime_type: mime_type,
        filename: filename
      }
    end
  end
end
