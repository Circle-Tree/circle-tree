# frozen_string_literal: true

class RemoveLeaderIdFromGroups < ActiveRecord::Migration[5.2]
  def change
    remove_reference :groups, :leader, foreign_key: { to_table: :users }
  end
end
