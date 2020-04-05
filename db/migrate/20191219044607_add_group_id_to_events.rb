# frozen_string_literal: true

class AddGroupIdToEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :group, foreign_key: true
  end
end
