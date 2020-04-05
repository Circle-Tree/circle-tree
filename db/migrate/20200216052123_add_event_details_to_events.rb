# frozen_string_literal: true

class AddEventDetailsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :start_date, :datetime, null: false, comment: '開始日'
    add_column :events, :end_date, :datetime, null: false, comment: '終了日'
    add_column :events, :answer_deadline, :datetime, null: false, comment: '回答期限'
    add_column :events, :description, :text, null: false, comment: 'イベント説明'
    add_column :events, :amount, :integer, null: false, comment: 'イベントの金額'
    add_column :events, :pay_deadline, :datetime, null: false, comment: '支払い期限'
  end
end
