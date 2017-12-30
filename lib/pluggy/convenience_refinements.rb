module Pluggy
  # A bunch of refinements that just make life a bit easier. For further docs,
  # view the source.
  module ConvenienceRefinements
    refine String do
      # Stolen from ActiveSupport:
      # http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html
      # #method-i-underscore
      def underscore
        gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .tr(' ', '_')
          .downcase
      end

      # Un-underscore a string.
      #
      # @todo Capitolize really only works post ruby2.3, so it might be good to
      # test it in pre-2.3 versions
      def titleize
        split(/ |\_|\-/)
          .map(&:capitalize)
          .join
      end
    end

    refine Hash do
      # Maps all the keys to be symbols *without changing case*
      def symbolize_keys
        map { |k, v| [k.to_sym, v] }.to_h
      end
    end

    refine Array do
      # Converts to hash, then calls {Hash#symbolize_keys}
      def symbolize_keys
        to_h.symbolize_keys
      end
    end
  end
end
