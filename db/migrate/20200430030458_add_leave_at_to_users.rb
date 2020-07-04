# frozen_string_literal: true

class AddLeaveAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :leave_at, :datetime, comment: 'サービス退会時刻'
  end
end
