# frozen_string_literal: true

class AddIndexToGroupsGroupNumber < ActiveRecord::Migration[5.2]
  def change
    add_index :groups, :group_number, unique: true
  end
end
