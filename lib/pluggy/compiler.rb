module Pluggy
  class Compiler
    attr_reader :name

    def initialize(name, &block)
      @block = block
      @name = name.downcase.to_sym
    end

    def run(text, b = @block.binding)
      @block.call(text, b)
    end
  end

  class CompilerCollection
    def initialize
      @compilers = []
    end

    def create(name, &block)
      @compilers.push Compiler.new(name, &block)
    end

    def [](name)
      compiler(name)
    end

    def method_missing(m, *args, &block)
      return compiler(m).run(*args, &block) if compiler_names.include?(m)
      super
    end

    def respond_to_missing?(m, *args, &block)
      compiler_names.include?(m) || super
    end

    def compile(file, b = TOPLEVEL_BINDING)
      file = File.new(file)
      extensions = File.basename(file).split('.')[1..-1]
      valid_exts = extensions.map(&:to_sym) & compiler_names.map(&:to_sym)
      valid_exts.inject(file.read) do |content, ext|
        compiler(ext).run(content, b)
      end
    end

    private

    def compilers(name)
      @compilers.select { |compiler| compiler.name == name }
    end

    def compiler(name)
      @compilers.select { |compiler| compiler.name == name }[0]
    end

    def compiler_names
      @compilers.map(&:name)
    end
  end
end
