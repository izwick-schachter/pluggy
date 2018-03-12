require 'test_helper'

class HooksTest < MiniTest::Test
  def setup
    @hooks = Pluggy::Hooks.new
    @hooks.register to: :foo do |data|
      data + 1
    end
    @hooks.register to: :bar do |data|
      data + 2
    end
    @hooks.register to: :bar do |data|
      data + 3
    end
  end

  def test_hooks_can_be_called
    assert_equal [2], @hooks.call_hooks(:foo, 1)
  end

  def test_layered_hooks
    # 1+2 + 1+3 == 7
    # I'm not sure how much I like the layered behavior, but it makes sense-ish
    # because each hook should get the same input (so they can't get the previous
    # hooks output) and I can't just drop all the duplicates.
    assert_equal 7, @hooks.call_hooks(:bar, 1).sum
  end
end
