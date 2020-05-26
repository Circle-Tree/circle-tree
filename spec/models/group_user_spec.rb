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
      it { is_expected.to define_enum_for(:role).with_values(
        general: 10,
        executive: 90
      ) }
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
end
