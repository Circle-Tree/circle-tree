require 'rails_helper'

RSpec.describe Group, type: :model do
  it 'ユーザーは有効なファクトリを持つこと' do
    expect(build(:group)).to be_valid
  end

  describe 'バリデーション' do
    context 'サークル名に関して' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(100) }
    end

    context 'メールアドレスに関して' do
      it { is_expected.to validate_presence_of(:email) }
      it '英語だけは無効であること' do
        group = build(:group, email: 'a' * 8)
        group.valid?
        expect(group.errors[:email]).to include('に間違いがあります。')
      end
      it '数字だけは無効であること' do
        group = build(:group, email: '1' * 8)
        group.valid?
        expect(group.errors[:email]).to include('に間違いがあります。')
      end
      it '@の使い方がおかしければ無効であること' do
        group = build(:group, email: 'aaa@@')
        group.valid?
        expect(group.errors[:email]).to include('に間違いがあります。')
      end
    end

    context 'サークルIDに関して' do
      it { is_expected.to validate_presence_of(:group_number) }
      it { is_expected.to validate_length_of(:group_number).is_at_least(6).is_at_most(25) }
      it { is_expected.to validate_uniqueness_of(:group_number) }
      it '漢字は無効であること' do
        group = build(:group, group_number: '太郎aa111111')
        group.valid?
        expect(group.errors[:group_number]).to include('に間違いがあります。')
      end
      it 'ひらがなは無効であること' do
        group = build(:group, group_number: 'ああああaaa11111')
        group.valid?
        expect(group.errors[:group_number]).to include('に間違いがあります。')
      end
      it '英語だけは無効であること' do
        group = build(:group, group_number: 'taroutarou')
        group.valid?
        expect(group.errors[:group_number]).to include('に間違いがあります。')
      end
      it '数字だけは無効であること' do
        group = build(:group, group_number: '11112222')
        group.valid?
        expect(group.errors[:group_number]).to include('に間違いがあります。')
      end
      it '記号は無効であること' do
        group = build(:group, group_number: 'aaaaaaa1?')
        group.valid?
        expect(group.errors[:group_number]).to include('に間違いがあります。')
      end
    end

    context '支払い状況に関して' do
      it { is_expected.to define_enum_for(:payment_status).with_values(
        unpaid: 0,
        paid: 1,
        inactive: 2
      ) }
    end
  end

  describe '関連付け' do
    it { is_expected.to have_many(:group_users) }
    it { is_expected.to have_many(:users).through(:group_users) }
    it { is_expected.to have_many(:events) }
    it { is_expected.to have_many(:transactions) }
  end

  describe 'インスタンスメソッド' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:group1) { create(:group) }
    let(:group2) { create(:group) }

    context 'set_paid' do
      it 'paidを返す' do
        unpaid_group = create(:group, :unpaid)
        expect(unpaid_group.set_paid).to eq Group.payment_statuses[:paid]
      end
    end

    context 'my_group?' do
      it 'trueを返す' do
        create(:group_user, group_id: group1.id, user_id: user1.id)
        expect(group1.my_group?(user1)).to be_truthy
      end

      it 'falseを返す' do
        expect(group1.my_group?(user2)).to be_falsey
      end
    end

    context 'my_own_group?' do
      it 'trueを返す' do
        create(:group_user, :executive, group_id: group2.id, user_id: user1.id)
        expect(group2.my_own_group?(user1)).to be_truthy
      end

      it 'falseを返す' do
        create(:group_user, group_id: group1.id, user_id: user1.id)
        expect(group1.my_own_group?(user1)).to be_falsey
      end
    end
  end

  describe 'クラスタンスメソッド' do
    let!(:group1) { create(:group) }
    let!(:group2) { create(:group) }
    let!(:group3) { create(:group) }
    let!(:group4) { create(:group) }
    let!(:user) { create(:user) }
    let!(:group_user1) { create(:group_user, :executive, group_id: group1.id, user_id: user.id) }
    let!(:group_user2) { create(:group_user, group_id: group2.id, user_id: user.id) }
    let!(:group_user3) { create(:group_user, group_id: group3.id, user_id: user.id) }

    context 'my_groups' do
      it '自分の所属するサークルを返す' do
        expect(Group.my_groups(user)).to eq [group1, group2, group3]
      end
      it '自分の所属しないサークルは返さない' do
        expect(Group.my_groups(user)).to_not include group4
      end
    end

    context 'my_own_groups' do
      it '自分が幹事であるサークルを返す' do
        expect(Group.my_own_group(user)).to eq group1
      end
      it '自分がメンバーであるサークルは返さない' do
        expect(Group.my_own_group(user)).to_not eq group2
      end
      it '自分の所属しないサークルは返さない' do
        expect(Group.my_own_group(user)).to_not eq group4
      end
    end

    context 'my_general_groups' do
      it '自分がメンバーであるサークルを返す' do
        expect(Group.my_general_groups(user)).to eq [group2, group3]
      end
      it '自分が幹事であるサークルを返さない' do
        expect(Group.my_general_groups(user)).to_not include group1
      end
      it '自分の所属しないサークルは返さない' do
        expect(Group.my_general_groups(user)).to_not include group4
      end
    end
  end
end
