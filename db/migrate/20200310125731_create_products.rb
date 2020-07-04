# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :paypal_plan_name
    end
    add_money :products, :price, currency: { present: true }
  end
end
