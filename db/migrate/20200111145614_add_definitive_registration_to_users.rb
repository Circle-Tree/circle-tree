# frozen_string_literal: true

class AddDefinitiveRegistrationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :definitive_registration, :boolean, default: true, null: false
  end
end
