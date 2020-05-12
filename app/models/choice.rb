# frozen_string_literal: true

class Choice < ApplicationRecord
  validates :content, presence: false
  validates :content, allow_blank: true
end
