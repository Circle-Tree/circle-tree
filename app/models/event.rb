# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :transactions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :users, through: :answers
  validates :name, presence: true, length: { maximum: 128 }
  validates :start_date, presence: true
  validate  :start_date_not_before_today
  validates :end_date, presence: true
  validate  :end_date_not_before_start_date
  validate  :answer_deadline_not_before_today
  validates :description, length: { maximum: 1024 }
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate  :pay_deadline_not_before_today
  validates :comment, length: { maximum: 40 }

  def self.my_events(user)
    group_ids = []
    Group.my_groups(user).each do |group|
      group_ids << group.id
    end
    Event.where(group_id: group_ids)
  end

  def self.my_attending_events(user)
    group_ids = []
    Group.my_groups(user).each do |group|
      group_ids << group.id
    end
    Event.where(group_id: group_ids).joins(:answers).where(answers: { status: 'attending' })
  end

  private

    # 開始日は今日以降の日付
    def start_date_not_before_today
      errors.add(:start_date, 'は今日以降のものを選択してください') if start_date.blank? || start_date < Date.today.to_datetime
    end

    # 終了日は開始日以降の日付
    # 現状は今日以降の日付となってしまっている
    def end_date_not_before_start_date
      errors.add(:end_date, 'は開始日以降のものを選択してください') if end_date.blank? || end_date < Date.today.to_datetime
    end

    # 回答期日は今日以降の日付
    def answer_deadline_not_before_today
      return if answer_deadline.blank?

      errors.add(:answer_deadline, 'は今日以降のものを選択してください') if answer_deadline < Date.today.to_datetime
    end

    # 支払い期日は今日以降の日付
    def pay_deadline_not_before_today
      return if pay_deadline.blank?

      errors.add(:pay_deadline, 'は今日以降のものを選択してください') if pay_deadline < Date.today.to_datetime
    end
end
