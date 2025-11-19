class PomodoroSessionsController < ApplicationController
  protect_from_forgery with: :exception

  def index
    if current_user
      @sessions = PomodoroSession.where(user_id: current_user.id).order(ended_at: :desc).limit(50)
    else
      @sessions = PomodoroSession.where(user_id: nil).order(ended_at: :desc).limit(50)
    end
  end

  def create
    vid = cookies[:visitor_id]
    attrs = pomodoro_params.merge(visitor_id: vid)
    attrs[:user_id] = current_user&.id
    ps = PomodoroSession.new(attrs)
    if ps.save
      render json: { id: ps.id }, status: :created
    else
      render json: { errors: ps.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if current_user
      ps = PomodoroSession.where(user_id: current_user.id).find(params[:id])
    else
      ps = PomodoroSession.where(user_id: nil).find(params[:id])
    end
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
