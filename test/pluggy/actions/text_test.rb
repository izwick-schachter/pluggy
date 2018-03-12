require 'test_helper'

class TextTest < MiniTest::Test
  Text = Pluggy::Router::Route::Text

  class EverythingHasAToSMethod
    undef :to_s
  end

  def test_validation
    assert Text.valid?("haha \n fewjif <%!")
    refute Text.valid?(EverythingHasAToSMethod.new)
  end

  def test_creation
    t = Text.new('lalala', settings: Pluggy::Settings.new, view_class: Pluggy::View)
    assert_instance_of Text, t
    # Doesn't demand settings
    # refute_raises(Yikes!) do
    Text.new('lalala', view_class: Pluggy::View)
    # end
    assert_instance_of Pluggy::View, t.evaluate(mock_request.env, mock_request, {})
    assert_equal 'lalala', t.evaluate(mock_request.env, mock_request, {}).content
  end
end
