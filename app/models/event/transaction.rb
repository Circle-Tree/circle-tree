# frozen_string_literal: true

class Event::Transaction < Transaction
  def self.paid_total_amount(user)
    where(debtor_id: user.id).joins(event: :answers).distinct.where(event: { answers: { status: Answer.statuses[:attending] } }).sum('payment')
  end

  def self.event_total_amount_and_payment(answers)
    amount = 0
    payment = 0
    answers.each do |answer|
      transaction = Event::Transaction.find_by(event_id: answer.event_id, debtor_id: answer.user_id)
      amount += transaction.debt
      payment += transaction.payment
    end
    { expected_total_amount: amount, total_payment: payment }
  end

  def self.unpaid_total_amount(user)
    where(debtor_id: user.id).joins(event: :answers).distinct.where(event: { answers: { status: Answer.statuses[:attending] } }).sum('debt') - paid_total_amount(user)
  end

  def self.new_transaction_when_create_new_event(member:, creditor:, group:, event:)
    create!(
      deadline: event.pay_deadline,
      debt: event.amount,
      payment: 0,
      creditor_id: creditor.id,
      debtor_id: member.id,
      group_id: group.id,
      event_id: event.id,
      url_token: SecureRandom.hex(10)
    )
  end

  def update_transaction_when_update_event(creditor:, event:)
    update(
      deadline: event.pay_deadline,
      debt: event.amount,
      creditor_id: creditor.id,
      url_token: SecureRandom.hex(10)
    )
  end
end
