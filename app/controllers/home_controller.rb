class HomeController < ApplicationController
  def index
    if current_user
      scope = PomodoroSession.where(user_id: current_user.id)
    else
      scope = PomodoroSession.where(user_id: nil)
    end
    @total_count = scope.count
    @today_count = scope.for_date(Date.current).count
    @recent_sessions = scope.order(ended_at: :desc).limit(12)
  end
end
