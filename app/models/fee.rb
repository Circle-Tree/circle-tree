class Fee < ApplicationRecord
  belongs_to :event
  validates :amount, presence: true
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
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
end
