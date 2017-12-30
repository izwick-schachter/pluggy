module Pluggy
  # Compiler is a class which manages view compilation, from any source.
  #
  # It is a built-in for pluggy, not yet decoupled enough to be considered
  # replaceable.
  #
  # @todo Decouple this class to an extent where it can be easily replacable
  # @example Defining a new compiler
  #   require 'erb'
  #
  #   Compiler.new(:erb) do |text, b|
  #     ERB.new(text).result(b)
  #   end
  # @example Compiling text with ERB
  #   Compiler.erb("<%= 1+1 %>") #=> "2"
  # @example Compiling an ERB file
  #   # foo.html.erb
  #   <h1>I have a random number for you: <%= rand(0,10) %></h1>
  #
  #   # File in same directory
  #   filepath = File.join(Dir.pwd, 'foo.html.erb')
  #   Compiler.compile(filepath) #=> "2"
  class Compiler
    # The name of the compiler, for later access. Symbols are prefered,
    # because they play nice with {Compiler::Collection#method_missing}.
    attr_reader :name

    def initialize(name, &block)
      @block = block
      @name = name.downcase.to_sym
    end

    # Blocks are called in the context that they are created in and are
    # responsible for managing their own bindings. They should *not* expect to
    # have instance variables available to them that are in the binding they are
    # passed.
    #
    # @param text The value to be compiled by the compiler. Typically it
    #   is a String, but it can be anything, so long as the compiler @block
    #   can handle it.
    # @param [Binding] b Pass a binding which is also forewarded
    #   to the @block.
    def run(text, b = @block.binding)
      @block.call(text, b)
    end

    class Collection
      def initialize
        @compilers = []
      end

      # Generates a new compiler and appends it to the collection.
      # @param name The name to create the compiler at
      # @param block The compiler block
      def create(name, &block)
        @compilers.push Compiler.new(name, &block)
      end

      # Retrives the compiler with the name passed
      # @param name The name of the compiler to retrieve
      def [](name)
        compiler(name)
      end

      # Used for the aliasing of {Compiler#run} to Compiler.\<name\>
      def method_missing(m, *args, &block)
        return compiler(m).run(*args, &block) if compiler_names.include?(m)
        super
      end

      # Used for the aliasing of {Compiler#run} to Compiler.\<name\>
      # @see #method_missing
      def respond_to_missing?(m, *args, &block)
        compiler_names.include?(m) || super
      end

      # Compiles file with binding b. It also assumes which compilers to use
      # based on filetype.
      #
      # @param [String] file A valid filepath. An error will be thrown if the
      #   path is not valid
      # @param [Binding] b The binding in which to compile. This is passed
      #   directly to {Compiler#run}
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
end
