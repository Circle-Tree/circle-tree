# frozen_string_literal: true

class Choose < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :choice

  validates :questionnaire_id, uniqueness: { scope: [:choice_id] }
end
