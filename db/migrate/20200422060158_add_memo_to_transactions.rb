class AddMemoToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :memo, :string, comment: '支払い/貸し借りのメモ'
  end
end
