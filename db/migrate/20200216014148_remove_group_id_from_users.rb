# frozen_string_literal: true

class RemoveGroupIdFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_reference :users, :group, foreign_key: true
  end
end
