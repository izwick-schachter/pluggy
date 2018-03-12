require 'test_helper'

class ViewTest < Minitest::Test
  def setup
    @settings = Pluggy::Settings.new
    @settings[:compilers].create(:erb) do |text, b|
      ERB.new(text).result(b)
    end
  end

  def test_can_hold_content
    assert_equal 'Some weird content', Pluggy::View.new('Some weird content').content
  end

  def test_defaults_to_html
    assert_equal 'text/html', Pluggy::View.new('Some weird content').mime_type
  end

  def test_can_pass_mime_type
    assert_equal 'blahblahblah', Pluggy::View.new('Some weird content', mime_type: 'blahblahblah').mime_type
    assert_equal 'mehmehmeh', Pluggy::View.new(filename: 'test/resources/view.html.erb', mime_type: 'mehmehmeh').mime_type
  end

  def test_can_read_file
    view = Pluggy::View.new(filename: 'test/resources/view.html.erb', settings: @settings)
    assert_equal 'Hello! My name is <%= "fredrick" %>!', view.content(compiled: false).chomp # Because newlines
  end

  def test_can_compile_file
    view = Pluggy::View.new(filename: 'test/resources/view.html.erb', settings: @settings)
    assert_equal 'Hello! My name is fredrick!', view.compile.content(compiled: false).chomp # Because newlines
    # And double compiling shouldn't hurt
    assert_equal 'Hello! My name is fredrick!', view.compile.content.chomp
    assert_equal 'Hello! My name is fredrick!', view.compile.content(compiled: false).chomp
  end

  def test_can_implicitly_compile_file
    view = Pluggy::View.new(filename: 'test/resources/view.html.erb', settings: @settings)
    assert_equal 'Hello! My name is fredrick!', view.content.chomp # Because newlines
  end

  # Note: Views expect full filenames -- the asumming is done by Asset
end
