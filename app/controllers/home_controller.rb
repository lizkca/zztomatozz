class HomeController < ApplicationController
  def index
    vid = cookies[:visitor_id]
    @total_count = PomodoroSession.for_visitor(vid).count
    @today_count = PomodoroSession.for_visitor(vid).for_date(Date.current).count
    @recent_sessions = PomodoroSession.for_visitor(vid).order(ended_at: :desc).limit(12)
  end
end
