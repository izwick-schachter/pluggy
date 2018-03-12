require 'test_helper'

class SettingsTest < Minitest::Test
  def test_settings_creation
    settings = [
      Pluggy::Settings::Setting.new(foo: 'bar'),
      Pluggy::Settings::Setting.new(happy: true),
      Pluggy::Settings::Setting.new(power: 11)
    ]
    settings = Pluggy::Settings.new(settings)
    assert_equal 'bar', settings[:foo]
    # Settings.setting_name isn't a thing that works
    # assert_equal 'bar', settings.foo
    assert_equal true, settings[:happy]
    assert_equal 11, settings[:power]
  end

  def test_setting_lock
    setting = Pluggy::Settings::Setting.new foo: 'bar', locked: true
    setting.value = 'uh oh'
    # Maybe this should raise an error, but it doesn't
    # assert_raises('This setting is locked') { setting.value = 'uh oh' }
    assert_equal 'bar', setting.value
  end

  def test_setting_validation
    setting = Pluggy::Settings::Setting.new foo: 'abcdefg' do |val|
      val.include?('abc')
    end
    setting.value = 'hijklmnop'
    # Maybe this should raise an error, but it doesn't
    # assert_raises('Your change did not pase validation') { setting.value = 'hijklmnop' }
    assert_equal 'abcdefg', setting.value
  end

  def test_setting_reset
    setting = Pluggy::Settings::Setting.new foo: 'bar'
    setting.value = 'baz'
    assert_equal 'baz', setting.value
    setting.reset
    assert_equal 'bar', setting.value
  end

  def test_passthough_to_value
    setting = Pluggy::Settings::Setting.new foo: 'bar'
    # setting.upcase! # Fails because string literals are immutable.
    assert_equal 'BAR', setting.upcase
  end

  def test_setting_hash_notation
    settings = Pluggy::Settings.new(Pluggy::Settings::Setting.new(foo: 'bar'))
    settings[:foo] = 'baz'
    assert_equal 'baz', settings[:foo]
  end

  def test_get_vs_get_setting
    settings = Pluggy::Settings.new(Pluggy::Settings::Setting.new(foo: 'bar'))
    assert_instance_of Pluggy::Settings::Setting, settings.get_setting(:foo)
    assert_instance_of String, settings.get(:foo)
    assert_instance_of String, settings[:foo]
  end
end
