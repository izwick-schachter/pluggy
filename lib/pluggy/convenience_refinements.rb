module ConvenienceRefinements
  refine String do
    def underscore
      gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .tr(' ', '_')
        .downcase
    end

    def titleize
      split(/ |\_|\-/)
        .map(&:capitalize)
        .join
    end
  end

  refine Hash do
    def symbolize_keys
      map { |k, v| [k.to_sym, v] }.to_h
    end
  end

  refine Array do
    def symbolize_keys
      to_h.symbolize_keys
    end
  end
end
