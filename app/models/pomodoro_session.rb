class PomodoroSession < ApplicationRecord
  validates :visitor_id, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true
  validates :duration_seconds, numericality: { greater_than: 0 }

  before_validation :assign_date

  scope :for_visitor, ->(vid) { where(visitor_id: vid) }
  scope :for_date, ->(d) { where(date: d) }

  private

  def assign_date
    self.date ||= started_at&.to_date
  end
end
