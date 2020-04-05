# frozen_string_literal: true

class AddColumnsToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :debtor, foreign_key: { to_table: :users }
    add_reference :transactions, :creditor, foreign_key: { to_table: :users }
    add_reference :transactions, :event, foreign_key: true
    add_reference :transactions, :group, foreign_key: true
  end
end
