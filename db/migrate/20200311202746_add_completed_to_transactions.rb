# frozen_string_literal: true

class AddCompletedToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :completed, :boolean, default: false, null: false
  end
end
