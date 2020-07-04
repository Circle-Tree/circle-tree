# frozen_string_literal: true

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
      it {
        is_expected.to define_enum_for(:grade).with_values(
          other: 0,
          grade1: 1,
          grade2: 2,
          grade3: 3,
          grade4: 4,
          grade5: 5,
          grade6: 6
        )
      }
    end

    context '性別に関して' do
      it { is_expected.to allow_value(true).for(:gender) }
      it { is_expected.to allow_value(false).for(:gender) }
      it { is_expected.not_to allow_value(nil).for(:gender) }
    end

    context 'adminに関して' do
      it { is_expected.to allow_value(true).for(:admin) }
      it { is_expected.to allow_value(false).for(:admin) }
      it { is_expected.not_to allow_value(nil).for(:admin) }
    end

    context '仮登録に関して' do
      it { is_expected.to allow_value(true).for(:definitive_registration) }
      it { is_expected.to allow_value(false).for(:definitive_registration) }
      it { is_expected.not_to allow_value(nil).for(:definitive_registration) }
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

  describe 'クラスメソッド' do
    context 'executives' do
      let!(:group) { create(:group) }
      it '正しい幹事たちを返す' do
        executives = []
        3.times do
          executive = create(:user)
          create(:group_user, :executive, group_id: group.id, user_id: executive.id)
          executives << executive
        end
        5.times do
          general = create(:user)
          create(:general, group_id: group.id, user_id: general.id)
        end
        expect(User.executives(group)).to eq executives
        expect(User.executives(group).count).to eq 3
      end
    end

    context 'generals' do
      let!(:group) { create(:group) }
      it '正しい一般人たちを返す' do
        generals = []
        3.times do
          executive = create(:user)
          create(:group_user, :executive, group_id: group.id, user_id: executive.id)
        end
        5.times do
          general = create(:user)
          create(:general, group_id: group.id, user_id: general.id)
          generals << general
        end
        expect(User.generals(group)).to eq generals
        expect(User.generals(group).count).to eq 5
      end
    end

    context 'members' do
      let!(:group) { create(:group) }
      it '正しいメンバーたちを返す' do
        members = []
        3.times do
          executive = create(:user)
          create(:group_user, :executive, group_id: group.id, user_id: executive.id)
          members << executive
        end
        5.times do
          general = create(:user)
          create(:general, group_id: group.id, user_id: general.id)
          members << general
        end
        expect(User.members(group)).to eq members
        expect(User.members(group).count).to eq 8
      end
    end

    context 'members_by_grade' do
      let!(:group) { create(:group) }
      it '正しい1年生たちを返す' do
        members = []
        3.times do
          user = create(:user, grade: User.grades[:grade1])
          create(:group_user, group_id: group.id, user_id: user.id)
          members << user
        end
        5.times do
          user = create(:user, grade: User.grades[:grade2])
          create(:group_user, group_id: group.id, user_id: user.id)
        end
        expect(User.members_by_grade(group: group, grade: User.grades[:grade1])).to eq members
        expect(User.members_by_grade(group: group, grade: User.grades[:grade1]).count).to eq 3
      end
    end

    # 今度実装
    # context 'uncompleted_transactions_and_members' do
    # end

    context 'return_gender_format' do
      it '女ならばtrueを返す' do
        str = '女'
        expect(User.return_gender_format(str)).to be_truthy
      end
      it '男ならばfalseを返す' do
        str = '男'
        expect(User.return_gender_format(str)).to be_falsey
      end
      it '「女性」ならばnilを返す' do
        str = '女性'
        expect(User.return_gender_format(str)).to eq nil
      end
      it '「男性」ならばnilを返す' do
        str = '男性'
        expect(User.return_gender_format(str)).to eq nil
      end
      it '「あ」ならばnilを返す' do
        str = 'あ'
        expect(User.return_gender_format(str)).to eq nil
      end
      it '「a」ならばnilを返す' do
        str = 'a'
        expect(User.return_gender_format(str)).to eq nil
      end
      it '「1」ならばnilを返す' do
        str = 1
        expect(User.return_gender_format(str)).to eq nil
      end
    end

    context 'return_grade_format' do
      it '0ならば0を返す' do
        str = '0'
        expect(User.return_grade_format(str)).to eq 0
      end
      it '1ならば1を返す' do
        str = '1'
        expect(User.return_grade_format(str)).to eq 1
      end
      it '6ならば6を返す' do
        str = '6'
        expect(User.return_grade_format(str)).to eq 6
      end
      it '7ならばnilを返す' do
        str = '7'
        expect(User.return_grade_format(str)).to eq nil
      end
      it '-1ならばnilを返す' do
        str = 'nil'
        expect(User.return_grade_format(str)).to eq nil
      end
      it '「a1」ならばnilを返す' do
        str = 'a1'
        expect(User.return_gender_format(str)).to eq nil
      end
      # it '「1a」ならばnilを返す' do
      #   str = '1a'
      #   expect(User.return_gender_format(str)).to eq nil
      # end
      it '「あ」ならばnilを返す' do
        str = 'あ'
        expect(User.return_gender_format(str)).to eq nil
      end
      it '「a」ならばnilを返す' do
        str = 'a'
        expect(User.return_gender_format(str)).to eq nil
      end
    end
  end
end
