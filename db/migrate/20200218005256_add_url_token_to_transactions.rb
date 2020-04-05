# frozen_string_literal: true

class AddUrlTokenToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :url_token, :string, null: false
  end
end
