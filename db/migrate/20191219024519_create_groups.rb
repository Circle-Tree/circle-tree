# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.references :leader, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
