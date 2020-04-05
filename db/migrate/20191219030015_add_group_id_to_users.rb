# frozen_string_literal: true

class AddGroupIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :group, foreign_key: true
  end
end
