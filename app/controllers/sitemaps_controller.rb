class SitemapsController < ApplicationController
  def index
    @base = request.base_url
    @urls = [
      root_path,
      stats_path,
      calendar_path,
      pomodoro_sessions_path
    ]
    respond_to do |format|
      format.xml
    end
  end
end
