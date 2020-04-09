class NewEventJob < ApplicationJob
  queue_as :default

  # create transaction to group members when create a event.
  def perform(members:, current_user:, group:, event:, creditor:)
    members.each do |member|
      Event::Transaction.new_transaction_when_create_new_event(member: member, creditor: creditor, group: group, event: event)
      Answer.new_answer_when_create_new_event(member, event)
      begin
        NotificationMailer.send_when_make_new_event(member, current_user, group, event).deliver_later(wait: 1.minute)
        puts 'イベント作成メール送信完了'
      rescue => e
        ErrorUtility.log_and_notify e
      end
    end
  end
end
