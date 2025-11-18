require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index loads" do
    get "/", headers: { "HTTP_COOKIE" => "visitor_id=testvid" }
    assert_response :success
    assert_includes @response.body, "25:00"
    assert_includes @response.body, "工作时长(分钟)"
  end
end
