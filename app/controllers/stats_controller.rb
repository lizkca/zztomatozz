class StatsController < ApplicationController
  def show
    if current_user
      scope = PomodoroSession.where(user_id: current_user.id)
    else
      scope = PomodoroSession.where(user_id: nil)
    end
    @total_count = scope.count
    @today_count = scope.for_date(Date.current).count
  end

  def calendar
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    @year = year
    @month = month
    if current_user
      scope = PomodoroSession.where(user_id: current_user.id)
    else
      scope = PomodoroSession.where(user_id: nil)
    end
    @counts = scope.where(date: start_date..end_date).group(:date).count
  end
end
