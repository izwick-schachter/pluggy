module Pluggy
  COMPILERS = {}
  class Compiler
    def initialize(name, &block)
      Pluggy::COMPILERS[name] = self
      @block = block
      @name = name.downcase.to_sym
    end

    def run(text, b = @block.binding)
      assets = File.join(Pluggy::ROOT, "assets")
      file = File.join(assets, "#{text}.#{@name}")
      text = File.read(file) if File.exist?(file)
      View.new @block.call(text, b)
    end

    class << self
      def method_missing(m, *args, &block)
        Pluggy::COMPILERS.keys.include?(m) ? Pluggy::COMPILERS[m].run(*args, &block) : super
      end

      def respond_to_missing?(m, *args, &block)
        Pluggy::COMPILERS.keys.include?(m) || super
      end
    end
  end
end
