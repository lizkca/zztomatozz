require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "show loads" do
    get "/stats", headers: { "HTTP_COOKIE" => "visitor_id=testvid" }
    assert_response :success
  end

  test "calendar loads" do
    get "/calendar", headers: { "HTTP_COOKIE" => "visitor_id=testvid" }
    assert_response :success
    assert_includes @response.body, "返回首页"
  end
end
