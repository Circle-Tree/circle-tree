# frozen_string_literal: true

class Transaction < ApplicationRecord
  attribute :url_token, :string, default: SecureRandom.hex(10)
  belongs_to :creditor, class_name: 'User', foreign_key: 'creditor_id'
  belongs_to :debtor, class_name: 'User', foreign_key: 'debtor_id'
  belongs_to :event
  belongs_to :group
  validate  :deadline_before_today
  validates :debt, presence: true
  validates :debt, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :payment, presence: true
  validates :payment, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validate :payment_is_equal_or_smaller_than_debt
  validates :type, presence: true
  validates :url_token, presence: true, uniqueness: true
  validates :completed, inclusion: { in: [true, false] }

  def to_param
    url_token
  end

  def completed?
    completed
  end

  def total_payment
    count('payment')
  end

  def expected_total_payment
    count('debt')
  end

  def self.total_payment_by_user(user)
    # Transaction.where(debtor_id: user.id, completed: true).joins(event: :answers).where(event: { answers: { status: 'attending' } }).sum('debt')
    Transaction.joins(event: :answers).where(debtor_id: user.id, completed: true, event: { answers: { status: 'attending' } }).distinct.sum('debt')
  end

  private

    def deadline_before_today
      errors.add(:deadline, 'は今日以降のものを選択してください') if deadline.nil? || deadline < Date.today.to_datetime
    end

    def payment_is_equal_or_smaller_than_debt
      errors.add(:payment, 'は支払うべき金額以下でなければなりません') if payment > debt
    end
end
