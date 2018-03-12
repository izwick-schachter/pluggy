require 'test_helper'

class BlockTest < MiniTest::Test
  Block = Pluggy::Router::Route::Block

  def test_validation
    assert Block.valid?(proc { true })
    assert(Block.valid? { true })
    refute Block.valid?('lalalala')
  end

  def test_creation
    b = Block.new(proc { 'foobar' }, settings: Pluggy::Settings.new, view_class: Pluggy::View)
    assert_instance_of Block, b
    assert_instance_of Pluggy::View, b.evaluate(mock_request.env, mock_request, {})
    assert_equal 'foobar', b.evaluate(mock_request.env, mock_request, {}).content
  end
end
