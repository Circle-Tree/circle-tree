# frozen_string_literal: true

class AddReasonToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :reason, :integer, null: false, default: 0
  end
end
