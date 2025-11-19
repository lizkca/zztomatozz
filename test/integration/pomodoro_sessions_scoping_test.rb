require "test_helper"

class PomodoroSessionsScopingTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "u@example.com", password: "secret", password_confirmation: "secret")
    PomodoroSession.create!(visitor_id: "vid1", user_id: nil, started_at: Time.current - 30.minutes, ended_at: Time.current - 5.minutes, duration_seconds: 1500, date: Date.current, label: "匿名A")
    PomodoroSession.create!(visitor_id: "vid2", user_id: nil, started_at: Time.current - 60.minutes, ended_at: Time.current - 35.minutes, duration_seconds: 1500, date: Date.current, label: "匿名B")
    PomodoroSession.create!(visitor_id: "vid3", user_id: @user.id, started_at: Time.current - 20.minutes, ended_at: Time.current - 5.minutes, duration_seconds: 900, date: Date.current, label: "我的番茄")
  end

  test "anonymous sees shared records" do
    get "/pomodoro_sessions", headers: { "HTTP_COOKIE" => "visitor_id=vid1" }
    assert_response :success
    assert_includes @response.body, "匿名A"
    assert_includes @response.body, "匿名B"
    assert_not_includes @response.body, "我的番茄"
  end

  test "logged in sees own records" do
    post "/session", params: { email: @user.email, password: "secret" }
    follow_redirect!
    get "/pomodoro_sessions"
    assert_response :success
    assert_includes @response.body, "我的番茄"
    assert_not_includes @response.body, "匿名A"
  end
end
