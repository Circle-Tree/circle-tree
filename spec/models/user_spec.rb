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
    # it { is_expected.to have_many(:groups).through(:group_users) }
    it { is_expected.to have_many(:answers) }
    it { is_expected.to have_many(:events).through(:answers) }
    # it { is_expected.to have_many(:transactions).with_foreign_key('debtor_id') }
    # it { is_expected.to have_many(:transactions).with_foreign_key('creditor_id') }
    it { is_expected.to have_many(:questionnaires) }
  end

  describe 'インスタンスメソッド' do
    context 'admin?' do
      it 'trueを返す' do
        admin_user = create(:user, :admin)
        expect(admin_user.admin?).to be_truthy
      end
      it 'falseを返す' do
        nonadmin_user = create(:user, admin: false)
        expect(nonadmin_user.admin?).to be_falsey
      end
    end

    context 'executive?' do
      let(:group) { create(:group) }
      let(:user) { create(:user) }
      it 'trueを返す' do
        create(:group_user, :executive, group_id: group.id, user_id: user.id)
        expect(user.executive?(group)).to be_truthy
      end
      it 'falseを返す' do
        create(:general, group_id: group.id, user_id: user.id)
        expect(user.executive?(group)).to be_falsey
      end
    end

    context 'attending?' do
      let(:event) { create(:event) }
      let(:user) { create(:user) }
      it '出席ならtrueを返す' do
        create(:attending, event_id: event.id, user_id: user.id)
        expect(user.attending?(event)).to be_truthy
      end
      it '欠席ならfalseを返す' do
        create(:answer, :absent, event_id: event.id, user_id: user.id)
        expect(user.attending?(event)).to be_falsey
      end
      it '未回答ならfalseを返す' do
        create(:answer, :unanswered, event_id: event.id, user_id: user.id)
        expect(user.attending?(event)).to be_falsey
      end
    end

    context 'is_gender_boolean?' do
      # let(:user) { create(:user) }
      it 'trueを返す' do
        user = create(:user)
        expect(user.is_gender_boolean?).to be_truthy
      end
    end

    context 'to_readable_grade' do
      it '1を返す' do
        user = create(:user, grade: User.grades[:grade1])
        expect(user.to_readable_grade).to eq 1
      end
      it '5を返す' do
        user = create(:user, grade: User.grades[:grade5])
        expect(user.to_readable_grade).to eq 5
      end
      it 'その他を返す' do
        user = create(:user, grade: User.grades[:other])
        expect(user.to_readable_grade).to eq 'その他'
      end
    end

    context 'to_readable_gender' do
      it '女性を返す' do
        user = create(:user, gender: true)
        expect(user.to_readable_gender).to eq '女性'
      end
      it '男性を返す' do
        user = create(:user, gender: false)
        expect(user.to_readable_gender).to eq '男性'
      end
    end

    context 'leave' do
      it 'trueを返す' do
        user = create(:user, leave_at: nil)
        user.leave
        expect(user.leave_at.present?).to be_truthy
      end
    end
  end
end
