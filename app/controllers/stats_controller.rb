class StatsController < ApplicationController
  def show
    vid = cookies[:visitor_id]
    @total_count = PomodoroSession.for_visitor(vid).count
    @today_count = PomodoroSession.for_visitor(vid).for_date(Date.current).count
  end

  def calendar
    vid = cookies[:visitor_id]
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    @year = year
    @month = month
    @counts = PomodoroSession.for_visitor(vid).where(date: start_date..end_date).group(:date).count
  end
end
