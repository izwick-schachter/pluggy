require 'test_helper'

class AssetTest < MiniTest::Test
  Asset = Pluggy::Router::Route::Asset

  def setup
    @settings = Pluggy::Settings.new
    @settings[:asset_path] = 'test/resources'
    @settings[:compilers].create :erb do |text, b|
      ERB.new(text).result(b)
    end
  end

  def test_validation
    assert Asset.valid?('view.html.erb', settings: @settings)
    assert Asset.valid?('view', settings: @settings)
    assert Asset.valid?('view.html', settings: @settings)
    refute Asset.valid?('somefile', settings: @settings)
    refute Asset.valid?(14, settings: @settings)
  end

  def test_creation
    a = Asset.new('view.html.erb', settings: @settings, view_class: Pluggy::View)
    assert_instance_of Asset, a
    assert_instance_of Pluggy::View, a.evaluate(mock_request.env, mock_request, {})
    assert_equal 'Hello! My name is fredrick!', a.evaluate(mock_request.env, mock_request, {}).content.chomp
  end

  def test_partial_assumption
    a = Asset.new('view.html', settings: @settings, view_class: Pluggy::View)
    assert_equal 'Hello! My name is fredrick!', a.evaluate(mock_request.env, mock_request, {}).content.chomp
  end

  def test_assumption
    a = Asset.new('view', settings: @settings, view_class: Pluggy::View)
    assert_equal 'Hello! My name is fredrick!', a.evaluate(mock_request.env, mock_request, {}).content.chomp
  end
end
