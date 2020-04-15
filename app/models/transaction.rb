# frozen_string_literal: true

class Transaction < ApplicationRecord
  attribute :url_token, :string, default: SecureRandom.hex(10)
  belongs_to :creditor, class_name: 'User', foreign_key: 'creditor_id'
  belongs_to :debtor, class_name: 'User', foreign_key: 'debtor_id'
  belongs_to :event
  belongs_to :group
  validate  :deadline_before_today, on: :create
  validates :debt, presence: true
  validates :debt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :payment, presence: true
  validates :payment, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validate :payment_is_equal_or_smaller_than_debt
  validates :type, presence: true
  validates :url_token, presence: true, uniqueness: true

  def to_param
    url_token
  end

  def completed?
    debt == payment
  end

  def uncompleted?
    debt > payment
  end

  def overpayment?
    debt < payment
  end

  def total_payment
    count('payment')
  end

  def expected_total_payment
    count('debt')
  end

  def self.total_payment_by_user(user)
    Transaction.joins(event: :answers).where(debtor_id: user.id, completed: true, event: { answers: { status: 'attending' } }).distinct.sum('debt')
  end

  def self.transactions_for_attending_event_by_user(user)
    Transaction.includes(event: :answers).where(debtor_id: user.id, event: { answers: { status: 'attending' } }).distinct
  end

  def self.uncompleted_transactions_by_user(transactions)
    uncompleted_transactions = []
    transactions.each do |transaction|
      uncompleted_transactions << transaction if transaction.debt != transaction.payment
    end
    uncompleted_transactions
  end

  def self.overdue_transactions_by_user(uncompleted_transactions:, today:)
    overdue_transactions = []
    uncompleted_transactions.each do |transaction|
      overdue_transactions << transaction if transaction.deadline < today
    end
    overdue_transactions
  end

  def self.urgent_transactions_by_user(non_overdue_transactions:, max:, today:)
    urgent_transactions = []
    non_overdue_transactions.each do |transaction|
      count = 0
      if transaction.deadline < today.since(7.days)
        urgent_transactions << transaction
        count += 1
      end
      break if count == max
    end
    urgent_transactions
  end

  private

    def deadline_before_today
      errors.add(:deadline, 'は今日以降のものを選択してください') if deadline.nil? || deadline < Date.today.to_datetime
    end

    def payment_is_equal_or_smaller_than_debt
      errors.add(:payment, 'は支払うべき金額以下でなければなりません') if payment > debt
    end
end
