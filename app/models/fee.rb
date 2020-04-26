class Fee < ApplicationRecord
  belongs_to :event
  belongs_to :creditor, class_name: 'User', foreign_key: 'creditor_id'
  validates :amount, presence: true
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 100_000_000 }, allow_blank: true
  enum grade: {
    other: 0,
    grade1: 1,
    grade2: 2,
    grade3: 3,
    grade4: 4,
    grade5: 5,
    grade6: 6
  }
  validates :grade, presence: true
  validate :deadline_not_before_today

  private

    def deadline_not_before_today
      errors.add(:deadline, 'は今日以降のものを選択してください') if deadline.nil? || deadline < Date.today.to_datetime
    end
end
