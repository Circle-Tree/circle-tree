# frozen_string_literal: true

class Event::Transaction < Transaction
  def self.paid_total_amount(user)
    where(debtor_id: user.id).joins(event: :answers).distinct.where(event: { answers: { status: Answer.statuses[:attending] } }).sum('payment')
  end

  def self.paid_event_total_amount(event:)
    where(event_id: event.id).sum('payment')
  end

  # 未完成
  def self.expected_event_total_amount(event:)
    includes(event: :answers).where(event_id: event.id, event: { answers: { status: Answer.statuses[:attending] } }).sum('debt')
  end

  def self.unpaid_total_amount(user)
    where(debtor_id: user.id).joins(event: :answers).distinct.where(event: { answers: { status: Answer.statuses[:attending] } }).sum('debt') - paid_total_amount(user)
  end

  def self.completed_transactions(event:)
    where(event_id: event.id, completed: true)
  end

  def self.uncompleted_transactions(event:)
    where(event_id: event.id, completed: false).joins(event: :answers).distinct.where(event: { answers: { status: Answer.statuses[:attending] }})
  end

  def self.new_transaction_when_create_new_event(member, user, group, event)
    create!(
      deadline: event.pay_deadline,
      debt: event.amount,
      payment: 0,
      creditor_id: user.id,
      debtor_id: member.id,
      group_id: group.id,
      event_id: event.id,
      url_token: SecureRandom.hex(10)
    )
  end

  def update_transaction_when_update_event(member:, user:, event:)
    update_attributes(
      deadline: event.pay_deadline,
      debt: event.amount,
      creditor_id: user.id,
      debtor_id: member.id,
      url_token: SecureRandom.hex(10)
    )
  end
end
