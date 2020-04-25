class NewTransactionsJob < ApplicationJob
  queue_as :default

  def perform(members:, event:, fee:, current_user:)
    members.each do |member|
      next unless member.attending?(event)

      edit_transaction = event.transactions.find_by(debtor_id: member.id).presence
      next if edit_transaction&.completed?

      begin
        edit_transaction&.attributes = {
          deadline: fee.deadline,
          debt: fee.amount,
          creditor_id: fee.creditor_id
        }
        if edit_transaction&.save(context: :new_transaction_job)
          TransactionNotificationMailer.edit_event_transaction(user: member, current_user: current_user, event: event).deliver_later
        else
          new_transaction = event.transactions.build(
            deadline: fee.deadline,
            debt: fee.amount,
            payment: 0,
            creditor_id: fee.creditor_id,
            debtor_id: member.id,
            url_token: SecureRandom.hex(10)
          )
          if new_transaction.save
            TransactionNotificationMailer.new_event_transaction(user: member, current_user: current_user, event: event).deliver_later
          else
            message = "#{current_user&.name}(#{current_user&.id})さんが#{member&.name}(#{member&.id})の支払い情報(#{event&.name}(#{event&.id}))作成に失敗"
            ErrorSlackNotification.general_error_notify(title: '支払い作成のエラー', message: message)
          end
        end
      rescue => e
        ErrorUtility.log_and_notify e
      end
    end
  end
end
