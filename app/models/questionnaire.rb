# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  belongs_to :user
  has_many :chooses, dependent: :destroy
  has_many :choices, through: :chooses

  validates :title, presence: true
  validates :title, length: { maximum: 128 }, allow_blank: true
  validates :content, presence: true
  validates :content, length: { maximum: 2048 }, allow_blank: true
  enum status: {
    created: 0, # 作成後
    open: 1, # 回答受付中
    closed: 2 # 回答終了
  }
end
