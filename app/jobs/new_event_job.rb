# frozen_string_literal: true

class NewEventJob < ApplicationJob
  queue_as :default

  # create transaction to group members when create a event.
  def perform(members:, current_user:, group:, event:)
    members.each do |member|
      # Event::Transaction.new_transaction_when_create_new_event(member: member, creditor: creditor, group: group, event: event)
      Answer.new_answer_when_create_new_event(user: member, event: event)
      begin
        NotificationMailer.send_when_make_new_event(user: member, current_user: current_user, group: group, event: event).deliver_later
      rescue StandardError => e
        ErrorUtility.log_and_notify e
      end
    end
  end
end
