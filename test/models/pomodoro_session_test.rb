require "test_helper"

class PomodoroSessionTest < ActiveSupport::TestCase
  test "valid session" do
    ps = PomodoroSession.new(
      visitor_id: "v1",
      started_at: Time.current,
      ended_at: Time.current + 25.minutes,
      duration_seconds: 1500,
      label: "专注",
      note: "测试"
    )
    assert ps.valid?
    assert_equal ps.started_at.to_date, ps.date
  end

  test "invalid without required fields" do
    ps = PomodoroSession.new
    assert_not ps.valid?
  end

  test "invalid duration" do
    ps = PomodoroSession.new(
      visitor_id: "v1",
      started_at: Time.current,
      ended_at: Time.current + 1.minute,
      duration_seconds: 0
    )
    assert_not ps.valid?
  end
end
