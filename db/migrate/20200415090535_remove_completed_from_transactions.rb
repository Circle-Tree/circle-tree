class RemoveCompletedFromTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :completed, :boolean
  end
end
