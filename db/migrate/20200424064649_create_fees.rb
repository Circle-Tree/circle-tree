# frozen_string_literal: true

class CreateFees < ActiveRecord::Migration[5.2]
  def change
    create_table :fees do |t|
      t.integer :amount, null: false, comment: '代金'
      t.integer :grade, null: false, comment: '学年'
      t.references :event, foreign_key: true, null: false, comment: 'イベント'

      t.timestamps
    end
    add_index :fees, %i[grade event_id], unique: true
  end
end
