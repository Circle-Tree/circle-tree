# frozen_string_literal: true

class AddDetailsToFees < ActiveRecord::Migration[5.2]
  def change
    add_column :fees, :deadline, :datetime, null: false, comment: '回答締切'
    add_reference :fees, :creditor, foreign_key: { to_table: :users }, comment: '貸した人'
  end
end
