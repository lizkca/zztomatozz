class AddUserIdToPomodoroSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :pomodoro_sessions, :user, foreign_key: true
  end
end
