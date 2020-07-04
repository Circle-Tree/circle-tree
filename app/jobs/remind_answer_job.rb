# frozen_string_literal: true

class RemindAnswerJob < ApplicationJob
  queue_as :default

  def perform
    today = Time.current.midnight
    day = today.since(3.days) # 3日前
    events = Event.includes(:group, :answers).where('answer_deadline >= ? AND answer_deadline <= ?', today, day)
    return unless events.present?

    events.each do |event|
      group = event.group
      answers = event.answers.includes(:user).where(status: Answer.statuses[:unanswered])
      answers.each do |answer|
        user = answer.user
        begin
          NotificationMailer.remind_answer(user, group, event).deliver_now
          puts '出欠催促メール送信完了'
        rescue StandardError => e
          ErrorUtility.log_and_notify e
        end
      end
    end
  end
end
