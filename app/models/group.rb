# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users
  has_many :events, dependent: :destroy
  has_many :transactions, dependent: :destroy
  validates :name, presence: true, length: { maximum: 100 }
  # email
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true
  validates :email, format: { with: VALID_EMAIL_REGEX }, allow_blank: true # 一意である必要はない
  # group_number
  VALID_GROUP_NUMBER_REGEX = /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]\w{6,25}\z/.freeze
  validates :group_number, presence: true
  validates :group_number, uniqueness: true,
                           format: { with: VALID_GROUP_NUMBER_REGEX },
                           length: { in: 6..25 },
                           allow_blank: true
  enum payment_status: { unpaid: 0, paid: 1, inactive: 2 }

  # インスタンスメソッド
  def set_paid
    self.payment_status = Group.payment_statuses[:paid]
  end

  def my_group?(user)
    Group.my_groups(user).include?(self)
  end

  def my_own_group?(user)
    self == Group.my_own_group(user)
  end

  # クラスメソッド
  def self.my_groups(user)
    groups = []
    GroupUser.where(user_id: user.id).each do |relationship|
      groups << Group.find(relationship.group_id)
    end
    groups
  end

  def self.my_own_group(user)
    relationship = GroupUser.find_by(user_id: user.id, role: GroupUser.roles[:executive])
    relationship.present? ? Group.find(relationship.group_id) : nil
  end

  def self.my_general_groups(user)
    Group.joins(:group_users).where(group_users: { user_id: user.id, role: GroupUser.roles[:general] })
  end
end
