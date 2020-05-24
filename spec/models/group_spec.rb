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
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:events) }
    it { is_expected.to have_many(:transactions) }
  end
end
