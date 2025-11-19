require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login page loads" do
    get new_session_path
    assert_response :success
  end
end
