# frozen_string_literal: true

class AddPaymentStatusToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :payment_status, :integer, null: false, default: 0, comment: '支払い状況'
  end
end
