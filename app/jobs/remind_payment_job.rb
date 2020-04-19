class RemindPaymentJob < ApplicationJob
  queue_as :default

  def perform
    today = Time.current.midnight
    day = today.since(3.days) # 3日前
    transactions = Event::Transaction.includes({ event: :group }, :debtor).where('deadline >= ? AND deadline <= ?', today, day)
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
