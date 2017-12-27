module Pluggy
  class Compiler
    def initialize(name, &block)
      Pluggy.settings[:compilers][name] = self
      @block = block
      @name = name.downcase.to_sym
    end

    def run(text, b = @block.binding)
      @block.call(text, b)
    end

    class << self
      def method_missing(m, *args, &block)
        return compilers[m].run(*args, &block) if compilers.keys.include?(m)
        super
      end

      def respond_to_missing?(m, *args, &block)
        compilers.keys.include?(m) || super
      end

      def compile(file, b = TOPLEVEL_BINDING)
        file = File.new(file)
        extensions = File.basename(file).split('.')[1..-1]
        valid_exts = extensions.map(&:to_sym) & compilers.keys.map(&:to_sym)
        valid_exts.inject(file.read) do |content, ext|
          compilers[ext].run(content, b)
        end
      end

      private

      def compilers
        Pluggy.settings[:compilers]
      end
    end
  end
end
