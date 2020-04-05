class RemindPaymentJob < ApplicationJob
  queue_as :default

  def perform
    day = Date.today.prev_day(3).to_time # 3日前
    today = Date.today.to_time
    transactions = Event::Transaction.includes({ event: :group }, :debtor).where('deadline >= ? AND deadline <= ?', day, today)
    return unless transactions.present?

    transactions.each do |transaction|
      event = transaction.event
      group = event.group
      debtor = transaction.debtor
      begin
        NotificationMailer.remind_payment(debtor, group, event, transaction).deliver_now
        puts '支払い催促メール送信完了'
      rescue => e
        ErrorUtility.log_and_notify e
      end
    end
  end
end
