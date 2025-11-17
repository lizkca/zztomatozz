require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index loads" do
    get "/", headers: { "HTTP_COOKIE" => "visitor_id=testvid" }
    assert_response :success
  end
end
