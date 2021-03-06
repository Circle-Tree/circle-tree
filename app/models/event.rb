# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many :transactions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :users, through: :answers
  has_many :fees, dependent: :destroy
  validates :name, presence: true, length: { maximum: 128 }
  validate  :start_date_not_before_today
  validate  :end_date_not_before_start_date
  validate  :answer_deadline_not_after_start_date
  validates :description, length: { maximum: 2048 }
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
    def answer_deadline_not_after_start_date
      if answer_deadline.blank? || answer_deadline < Date.today.to_datetime
        errors.add(:answer_deadline, 'は今日以降のものを選択してください')
      elsif start_date.present? && answer_deadline.present? && answer_deadline > start_date
        errors.add(:answer_deadline, 'は開始日以前のものを選択してください')
      end
    end
end
