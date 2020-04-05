# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.datetime :deadline
      t.integer :debt
      t.integer :payment, default: 0

      t.timestamps
    end
  end
end
