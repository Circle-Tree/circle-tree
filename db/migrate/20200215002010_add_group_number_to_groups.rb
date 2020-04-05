# frozen_string_literal: true

class AddGroupNumberToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :group_number, :string, null: false
  end
end
