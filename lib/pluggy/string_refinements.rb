module StringRefinements
  refine String do
    def underscore
      self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    def titleize
      self.split(/ |\_|\-/).
      map(&:capitalize).
      join
    end
  end
end