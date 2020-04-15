class RemovePayColumnsFromEvent < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :amount, :integer
    remove_column :events, :pay_deadline, :datetime
  end
end
