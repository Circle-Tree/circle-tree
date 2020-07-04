# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fee, type: :model do
  let(:today) { Time.current.midnight }

  it 'Feeは有効なファクトリを持つこと' do
    expect(build(:fee)).to be_valid
  end

  describe 'バリデーション' do
    context 'amountに関して' do
      it { is_expected.to validate_presence_of(:amount) }
      it '負数は無効であること' do
        fee = build(:fee, amount: -1)
        fee.valid?
        expect(fee.errors[:amount]).to include('は0以上の値にしてください')
      end
      it '少数は無効であること' do
        fee = build(:fee, amount: 1.5)
        fee.valid?
        expect(fee.errors[:amount]).to include('は整数で入力してください')
      end
      it '99_999_999は有効であること' do
        fee = build(:fee, amount: 99_999_999)
        expect(fee).to be_valid
      end
      it '100_000_000より大きいのは無効であること' do
        fee = build(:fee, amount: 100_000_001)
        fee.valid?
        expect(fee.errors[:amount]).to include('は100000000より小さい値にしてください')
      end
      it '100_000_000より大きいのは無効であること' do
        fee = build(:fee, amount: 100_000_000)
        fee.valid?
        expect(fee.errors[:amount]).to include('は100000000より小さい値にしてください')
      end
    end

    context '締切日に関して' do
      it '締切日がなければ無効であること' do
        fee = build(:fee, deadline: nil)
        fee.valid?
        expect(fee.errors[:deadline]).to include('は今日以降のものを選択してください')
      end
      it '今日であるのは有効であること' do
        fee = build(:fee, deadline: today)
        expect(fee).to be_valid
      end
      it '今日より前だと無効であること' do
        fee = build(:fee, deadline: today.ago(3.days))
        fee.valid?
        expect(fee.errors[:deadline]).to include('は今日以降のものを選択してください')
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
  end

  describe '関連付け' do
    it { is_expected.to belong_to(:creditor).with_foreign_key('creditor_id') }
    it { is_expected.to belong_to(:event) }
  end
end
