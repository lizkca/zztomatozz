require "test_helper"

class UserSignupTest < ActionDispatch::IntegrationTest
  test "signup success" do
    get new_user_path
    assert_response :success
    post users_path, params: { user: { email: "new@example.com", password: "secret", password_confirmation: "secret" } }
    follow_redirect!
    assert_response :success
    assert_includes @response.body, "new@example.com"
  end

  test "signup failure on mismatch" do
    post users_path, params: { user: { email: "bad@example.com", password: "secret", password_confirmation: "oops" } }
    assert_response :unprocessable_entity
    assert_includes @response.body, "Password confirmation"
  end
end
