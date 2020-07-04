# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupUser, type: :model do
  it 'GroupUserは有効なファクトリを持つこと' do
    expect(build(:group_user)).to be_valid
  end

  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    context '役割に関して' do
      it { is_expected.to validate_presence_of(:role) }
      it {
        is_expected.to define_enum_for(:role).with_values(
          general: 10,
          executive: 90
        )
      }
    end

    it 'ユーザーとグループはユニークであること' do
      create(:group_user, user_id: user.id, group_id: group.id)
      group_user = build(:group_user, user_id: user.id, group_id: group.id)
      group_user.valid?
      expect(group_user.errors[:group_id]).to include('は既に使用されています。')
    end
  end

  describe '関連付け' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
  end

  describe 'クラスメソッド' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:group) { create(:group) }
    let!(:group_user1) { create(:group_user, :executive, group_id: group.id, user_id: user2.id) }
    let!(:group_user2) { create(:general, group_id: group.id, user_id: user3.id) }

    context 'new_group' do
      it '新しいGroupUserが追加される' do
        expect do
          GroupUser.new_group(group, user1)
        end.to change(group.users, :count).by(1)
      end
      it 'executiveなGroupUserが追加される' do
        GroupUser.new_group(group, user1)
        relationship = GroupUser.last
        expect(relationship.role).to eq 'executive'
      end
    end

    context 'general_relationship' do
      it 'generalなGroupUserを返す' do
        expect(GroupUser.general_relationship(group: group, user: user2).blank?).to be_truthy
        expect(GroupUser.general_relationship(group: group, user: user3)).to eq group_user2
      end
    end

    context 'executive_relationship' do
      it 'executiveなGroupUserを返す' do
        expect(GroupUser.executive_relationship(group: group, user: user2)).to eq group_user1
        expect(GroupUser.executive_relationship(group: group, user: user3).blank?).to be_truthy
      end
    end

    context 'inherit' do
      it '引継ぎが成功すること' do
        GroupUser.inherit(group: group, current_user: user2, new_executive: user3)
        general_relationship = GroupUser.find_by(group_id: group.id, user_id: user2.id)
        executive_relationship = GroupUser.find_by(group_id: group.id, user_id: user3.id)
        expect(general_relationship.role).to eq 'general'
        expect(executive_relationship.role).to eq 'executive'
      end
    end
  end
end
