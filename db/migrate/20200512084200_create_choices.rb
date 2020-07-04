# frozen_string_literal: true

class CreateChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :choices do |t|
      t.string :content, null: false, comment: '選択肢内容'

      t.timestamps
    end
  end
end
