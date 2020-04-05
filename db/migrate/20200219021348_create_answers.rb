# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.integer :status, null: false, default: 10, comment: '回答のステータス'
      t.references :user,  foreign_key: true, index: false, null: false, comment: '回答者のUserID'
      t.references :event, foreign_key: true, index: false, null: false, comment: 'イベントID'

      t.timestamps
    end
    add_index :answers, %i[user_id event_id], unique: true
  end
end
