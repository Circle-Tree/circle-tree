class NewTransactionsJob < ApplicationJob
  queue_as :default

  def perform(members:, event:, params:, current_user:)
    members.each do |member|
      next unless member.attending?(event)

      edit_transaction = event.transactions.find_by(debtor_id: member.id).presence
      next if edit_transaction&.completed?

      begin
        if edit_transaction&.update(params)
          TransactionNotificationMailer.edit_event_transaction(user: member, current_user: current_user, event: event).deliver_later
        else
          new_transaction = event.transactions.build(params)
          new_transaction.debtor_id = member.id
          new_transaction.url_token = SecureRandom.hex(10)
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
