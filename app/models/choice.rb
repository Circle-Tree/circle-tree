# frozen_string_literal: true

class Choice < ApplicationRecord
  has_many :chooses, dependent: :destroy
  has_many :questionnaires, through: :chooses

  validates :content, presence: true
  validates :content, length: { maximum: 32 }, allow_blank: true
end
