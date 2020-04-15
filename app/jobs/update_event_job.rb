class UpdateEventJob < ApplicationJob
  queue_as :default

  # update transaction to group members when update a event.
  def perform(members:, current_user:, group:, event:)
    members.each do |member|
      # transaction = Transaction.find_by(event_id: event.id, debtor_id: member.id)
      # if transaction&.update_transaction_when_update_event(creditor: creditor, event: event)
      begin
        NotificationMailer.send_when_update_event(user: member, current_user: current_user, group: group, event: event).deliver_later
      rescue => e
        ErrorUtility.log_and_notify e
      end
      # end
    end
  end
end
