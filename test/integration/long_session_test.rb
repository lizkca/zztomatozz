require "test_helper"

class LongSessionTest < ActionDispatch::IntegrationTest
  test "login sets cookie with expires about six months" do
    user = User.create!(email: "long@example.com", password: "secret123", password_confirmation: "secret123")
    post session_path, params: { email: user.email, password: "secret123" }
    assert_response :redirect
    cookie = Array(@response.headers["Set-Cookie"]).join("\n")
    assert_includes cookie, "_zztomatozz_session"
    assert_match(/expires=/i, cookie)
    follow_redirect!
    assert_response :success
    assert_includes @response.body, user.email
  end
end
