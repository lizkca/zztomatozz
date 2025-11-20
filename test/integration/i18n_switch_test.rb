require "test_helper"

class I18nSwitchTest < ActionDispatch::IntegrationTest
  test "home in zh" do
    get "/?locale=zh"
    assert_response :success
    assert_includes @response.body, "开始"
  end

  test "home in en" do
    get "/?locale=en"
    assert_response :success
    assert_includes @response.body, "Start"
  end
end
