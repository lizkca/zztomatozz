class CreatePomodoroSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :pomodoro_sessions do |t|
      t.string :visitor_id, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at, null: false
      t.integer :duration_seconds, null: false
      t.string :label
      t.text :note
      t.date :date, null: false

      t.timestamps
    end

    add_index :pomodoro_sessions, :visitor_id
    add_index :pomodoro_sessions, :date
  end
end
