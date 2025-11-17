class PomodoroSessionsController < ApplicationController
  protect_from_forgery with: :exception

  def index
    vid = cookies[:visitor_id]
    @sessions = PomodoroSession.for_visitor(vid).order(ended_at: :desc).limit(50)
  end

  def create
    vid = cookies[:visitor_id]
    ps = PomodoroSession.new(pomodoro_params.merge(visitor_id: vid))
    if ps.save
      render json: { id: ps.id }, status: :created
    else
      render json: { errors: ps.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    vid = cookies[:visitor_id]
    ps = PomodoroSession.for_visitor(vid).find(params[:id])
    if ps.update(update_params)
      render json: { ok: true }
    else
      render json: { errors: ps.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def pomodoro_params
    params.require(:pomodoro_session).permit(:started_at, :ended_at, :duration_seconds, :label, :note, :date)
  end

  def update_params
    params.require(:pomodoro_session).permit(:label, :note)
  end
end
