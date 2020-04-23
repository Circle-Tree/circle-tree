# frozen_string_literal: true

class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user
  enum role: {
    general: 10,  # 一般人
    executive: 90 # 幹部
  }
  validates :group_id, uniqueness:{ scope: [:user_id] }
  validates :role, presence: true

  def self.new_group(group, user)
    GroupUser.create!(
      group_id: group.id,
      user_id: user.id,
      role: GroupUser.roles[:executive]
    )
  end

  def self.general_relationship(group:, user:)
    GroupUser.find_by(group_id: group.id, user_id: user.id, role: GroupUser.roles[:general])
  end

  def self.executive_relationship(group:, user:)
    GroupUser.find_by(group_id: group.id, user_id: user.id, role: GroupUser.roles[:executive])
  end

  def self.inherit(group:, current_user:, new_executive:)
    executive_relationship = GroupUser.executive_relationship(group: group, user: current_user)
    general_relationship = GroupUser.general_relationship(group: group, user: new_executive)
    begin
      GroupUser.transaction do
        executive_relationship.update!(role: GroupUser.roles[:general])
        general_relationship.update!(role: GroupUser.roles[:executive])
      end
      true
    rescue => e
      ErrorUtility.log_and_notify(e)
      false
    end
  end
end
