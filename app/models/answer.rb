# frozen_string_literal: true

class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :event
  enum status: {
    unanswered: 10, # 未回答
    attending: 20, # 出席
    absent: 30 # 欠席
  }
  validates :status, presence: true
  validates_uniqueness_of :event_id, scope: :user_id
  enum reason: {
    nothing: 0,
    job: 1,
    friend: 2,
    family: 3,
    money: 4,
    unfavorable: 5,
    other: 6
  }
  scope :my_attending_answers, ->(user) { where(user_id: user.id, status: Answer.statuses[:attending]) }

  def self.divide_answers_in_three(event)
    answers = event.answers
    {
      attending: answers.where(status: statuses[:attending]),
      absent: answers.where(status: statuses[:absent]),
      unanswered: answers.where(status: statuses[:unanswered])
    }
  end

  def self.attending_count(event:)
    where(event_id: event.id, status: statuses[:attending]).count
  end

  def self.absent_count(event:)
    where(event_id: event.id, status: statuses[:absent]).count
  end

  def self.unanswered_count(event:)
    where(event_id: event.id, status: statuses[:unanswered]).count
  end

  def self.new_answer_when_create_new_event(user:, event:)
    create!(
      status: statuses[:unanswered],
      user_id: user.id,
      event_id: event.id
    )
  end
end
