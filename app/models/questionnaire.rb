# frozen_string_literal: true

class Questionnaire < ApplicationRecord
  belongs_to :user
  validates :content, presence: true
  validates :content, length: { maximum: 2048 }, allow: blank
  enum status: {
    created: 0, # 作成後
    open: 1, # 回答受付中
    closed: 2 # 回答終了
  }
end
