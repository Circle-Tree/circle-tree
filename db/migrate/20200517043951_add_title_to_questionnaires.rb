# frozen_string_literal: true

class AddTitleToQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaires, :title, :string, null: false
  end
end
