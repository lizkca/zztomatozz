require "test_helper"

class PomodoroSessionsControllerTest < ActionDispatch::IntegrationTest
  test "create session" do
    started = Time.current
    ended = started + 25.minutes
    post "/pomodoro_sessions", params: {
      pomodoro_session: {
        started_at: started.iso8601,
        ended_at: ended.iso8601,
        duration_seconds: 1500,
        label: "标签",
        note: "备注",
        date: started.to_date.to_s
      }
    }, headers: { "HTTP_COOKIE" => "visitor_id=testvid" }
    assert_response :created
  end
end
