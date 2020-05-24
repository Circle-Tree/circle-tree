require 'rails_helper'

RSpec.describe User, type: :model do
  it 'ユーザーは有効なファクトリを持つこと' do
    expect(build(:user)).to be_valid
  end

  describe 'バリデーション' do
    context '氏名に関して' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(100) }
    end

    context 'フリガナに関して' do
      it { is_expected.to validate_presence_of(:furigana) }
      it '漢字は無効であること' do
        user = build(:user, furigana: 'ヤマダ太郎')
        user.valid?
        expect(user.errors[:furigana]).to include('は全角カタカナのみで入力して下さい。')
      end
      it '英語は無効であること' do
        user = build(:user, furigana: 'ヤマダtarou')
        user.valid?
        expect(user.errors[:furigana]).to include('は全角カタカナのみで入力して下さい。')
      end
      it '数字は無効であること' do
        user = build(:user, furigana: 'ヤマダ3')
        user.valid?
        expect(user.errors[:furigana]).to include('は全角カタカナのみで入力して下さい。')
      end
      it '記号は無効であること' do
        user = build(:user, furigana: 'ヤマダ?')
        user.valid?
        expect(user.errors[:furigana]).to include('は全角カタカナのみで入力して下さい。')
      end
    end

    context 'メールアドレスに関して' do
      it { is_expected.to validate_presence_of(:email) }
      let!(:original_user) { create(:user, email: 'original@example.com') }
      it '重複すれば無効であること' do
        user = build(:user, email: 'original@example.com')
        user.valid?
        expect(user.errors[:email]).to include('は既に使用されています。')
      end
    end

    context '学年に関して' do
      it { is_expected.to validate_presence_of(:grade) }
      it { is_expected.to define_enum_for(:grade).with_values(
        other: 0,
        grade1: 1,
        grade2: 2,
        grade3: 3,
        grade4: 4,
        grade5: 5,
        grade6: 6
      ) }
    end

    context '性別に関して' do
      it { is_expected.to validate_presence_of(:gender) }
    end

    context 'adminに関して' do
      it { is_expected.to validate_inclusion_of(:admin).in_array([true, false]) }
    end

    context '仮登録に関して' do
      it { is_expected.to validate_inclusion_of(:definitive_registration).in_array([true, false]) }
    end

    # context '利用規約に関して' do
    #   it { is_expected.to validate_acceptance_of(:agreement) }
    # end
  end

  describe '関連付け' do
    it { is_expected.to have_many(:group_users) }
    # it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:answers) }
    it { is_expected.to have_many(:events) }
    # it { is_expected.to have_many(:transactions).with_foreign_key('debtor_id') }
    # it { is_expected.to have_many(:transactions).with_foreign_key('creditor_id') }
    it { is_expected.to have_many(:questionnaires) }
  end
end
