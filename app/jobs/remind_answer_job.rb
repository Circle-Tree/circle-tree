class RemindAnswerJob < ApplicationJob
  queue_as :default

  def perform
    day = Date.today.prev_day(3).to_time # 3日前
    today = Date.today.to_time
    events = Event.includes(:group, :answers).where('answer_deadline >= ? AND answer_deadline <= ?', day, today)
    return unless events.present?

    events.each do |event|
      group = event.group
      answers = event.answers.includes(:user).where(status: Answer.statuses[:unanswered])
      answers.each do |answer|
        user = answer.user
        begin
          NotificationMailer.remind_answer(user, group, event).deliver_now
          puts '出欠催促メール送信完了'
        rescue => e
          ErrorUtility.log_and_notify e
        end
      end
    end
  end
end
