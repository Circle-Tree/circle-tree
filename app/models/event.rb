# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :transactions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :users, through: :answers
  validates :name, presence: true, length: { maximum: 128 }
  validate  :start_date_not_before_today
  validate  :end_date_not_before_start_date
  validate  :answer_deadline_not_before_today
  validates :description, length: { maximum: 1024 }
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate  :pay_deadline_not_before_today
  validates :comment, length: { maximum: 40 }

  def self.my_groups_events(user)
    group_ids = Group.my_groups(user).map(&:id)
    Event.where(group_id: group_ids)
  end

  def self.my_attending_events(user)
    group_ids = Group.my_groups(user).map(&:id)
    Event.where(group_id: group_ids).joins(:answers).where(answers: { status: 'attending' }).distinct
  end

  private

    # 開始日は今日以降の日付
    def start_date_not_before_today
      errors.add(:start_date, 'は今日以降のものを選択してください') if start_date.blank? || start_date < Date.today.to_datetime
    end

    # 終了日は開始日以降の日付
    def end_date_not_before_start_date
      start_date = self.start_date
      end_date = self.end_date
      if start_date.present? && end_date.present? && end_date < start_date
        errors.add(:end_date, 'は開始日以降のものを選択してください')
      elsif end_date.blank?
        errors.add(:end_date, 'は開始日以降のものを選択してください')
      end
    end

    # 回答期日は今日以降の日付
    def answer_deadline_not_before_today
      errors.add(:answer_deadline, 'は今日以降のものを選択してください') if answer_deadline.blank? || answer_deadline < Date.today.to_datetime
    end

    # 支払い期日は今日以降の日付
    def pay_deadline_not_before_today
      errors.add(:pay_deadline, 'は今日以降のものを選択してください') if pay_deadline.blank? || pay_deadline < Date.today.to_datetime
    end
end
