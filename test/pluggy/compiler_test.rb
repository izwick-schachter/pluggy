require 'test_helper'

class CompilerTest < Minitest::Test
  # rubocop:disable Metrics/MethodLength
  def setup
    @collection = Pluggy::Compiler::Collection.new
    @collection.create(:hello) do |content|
      "Hello, #{content}"
    end
    @collection.create(:greeting) do |content, b|
      b.instance_eval do
        "#{@greeting}, #{content}"
      end
    end
    erb_compiler = Pluggy::Compiler.new(:erb) do |text, b|
      ERB.new(text).result(b)
    end
    @collection << erb_compiler
    # This example intentionally doesn't work. It'll start working when ruby starts
    # supporting propper local variable setting and getting.
    @collection.create(:spaaace) do |content, b|
      b.instance_exec do
        content.gsub(' ', ' ' * num_spaces)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_can_add_compiler
    hello_compiler = @collection[:hello]
    assert_instance_of Pluggy::Compiler, hello_compiler
    assert_equal :hello, hello_compiler.name
  end

  def test_compiling_with_method_syntax
    assert_equal 'Hello, test', @collection.hello('test')
  end

  def test_instance_variable_with_passed_binding
    b = Object.new.send(:binding)
    b.instance_variable_set(:@greeting, 'Howdy')
    refute_equal 'Howdy', @greeting
    assert_equal 'Howdy, test', @collection.greeting('test', b)
  end

  def test_local_variable_with_passed_binding
    # Hint: It doesn't work
    b = Object.new.send(:binding)
    b.local_variable_set(:num_spaces, 2)
    assert_raises(NameError) { num_spaces }
    assert_raises(NameError) { @collection.spaaace('wow this is a lot of words', b) }
    # Uncomment the next test when the above test passes. See comment near compiler creation.
    # assert_equal 'wow  this  is  a  lot  of  words', @collection.spaaace('wow this is a lot of words', b)
  end

  def test_compiling_file_from_name
    # Note that view is a String, not a Pluggy::View
    content = @collection.compile('test/resources/view.html.erb')
    assert_equal 'Hello! My name is fredrick!', content.chomp # In case of newline
  end

  def test_compiling_file_from_file_obj
    # Note that view is a String, not a Pluggy::View
    content = @collection.compile(File.new('test/resources/view.html.erb'))
    assert_equal 'Hello! My name is fredrick!', content.chomp # In case of newline
  end

  # Note: The compiler expects full filenames -- the asumming is done by Asset
end
