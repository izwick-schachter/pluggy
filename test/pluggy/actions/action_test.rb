require 'test_helper'

class ActionTest < MiniTest::Test
  Pluggy::Router::Route::OPT_TO_TYPE.each do |action_name, action_class|
    define_method("test_#{action_name}_has_validation") do
      assert action_class.respond_to? :valid?
      params = action_class.method(:valid?).parameters
      # Takes one normal argument
      assert_equal(1, params.select { |type, _name| type == :req }.length) unless action_name == :block
      # Because blocks don't show up in #parameters
      # MUST take settings
      assert_equal(1, params.select { |type, name| (type == :key || type == :keyreq) && name == :settings }.length)
    end

    define_method("test_#{action_name}_can_be_enabled") do
      assert action_class.respond_to? :enabled?
      params = action_class.method(:enabled?).parameters
      assert_equal(1, params.select { |type, _name| type == :req }.length)
    end
  end
end
