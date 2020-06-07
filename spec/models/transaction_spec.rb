require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it 'イベント用収支は有効なファクトリを持つこと' do
    expect(build(:event_transaction)).to be_valid
  end

  it '個人収支は有効なファクトリを持つこと' do
    expect(build(:individual_transaction)).to be_valid
  end

  describe 'バリデーション' do
    context 'typeに関して' do
      it { is_expected.to validate_presence_of(:type) }
    end

    context 'debtに関して' do
      it { is_expected.to validate_presence_of(:debt) }
      it '負数は無効であること' do
        transaction = build(:transaction, debt: -1)
        transaction.valid?
        expect(transaction.errors[:debt]).to include('は0以上の値にしてください')
      end
      it '少数は無効であること' do
        transaction = build(:transaction, debt: 1.5)
        transaction.valid?
        expect(transaction.errors[:debt]).to include('は整数で入力してください')
      end
      it '99_999_999は有効であること' do
        transaction = build(:event_transaction, debt: 99999999)
        expect(transaction).to be_valid
      end
      it '100_000_000より大きいのは無効であること' do
        transaction = build(:transaction, debt: 100000001)
        transaction.valid?
        expect(transaction.errors[:debt]).to include('は100000000より小さい値にしてください')
      end
      it '100_000_000より大きいのは無効であること' do
        transaction = build(:transaction, debt: 100000000)
        transaction.valid?
        expect(transaction.errors[:debt]).to include('は100000000より小さい値にしてください')
      end
    end

    context 'paymentに関して' do
      it { is_expected.to validate_presence_of(:payment) }
      it '負数は無効であること' do
        transaction = build(:transaction, payment: -1)
        transaction.valid?
        expect(transaction.errors[:payment]).to include('は0以上の値にしてください')
      end
      it '少数は無効であること' do
        transaction = build(:transaction, payment: 1.5)
        transaction.valid?
        expect(transaction.errors[:payment]).to include('は整数で入力してください')
      end
      it '99_999_999は有効であること' do
        transaction = build(:event_transaction, debt: 99999999)
        expect(transaction).to be_valid
      end
      it '100_000_000より大きいのは無効であること' do
        transaction = build(:transaction, debt: 100000001)
        transaction.valid?
        expect(transaction.errors[:debt]).to include('は100000000より小さい値にしてください')
      end
      it '100_000_000より大きいのは無効であること' do
        transaction = build(:transaction, debt: 100000000)
        transaction.valid?
        expect(transaction.errors[:debt]).to include('は100000000より小さい値にしてください')
      end
      it 'debtより大きいのは無効であること' do
        transaction = build(:transaction, debt: 1000, payment: 1001)
        transaction.valid?
        expect(transaction.errors[:payment]).to include('は支払うべき金額以下でなければなりません')
      end
    end

    context 'url_tokenに関して' do
      it { is_expected.to validate_presence_of(:url_token) }
      it { is_expected.to validate_uniqueness_of(:url_token) }
    end
  end

  describe '関連付け' do
    it { is_expected.to belong_to(:debtor).with_foreign_key('debtor_id') }
    it { is_expected.to belong_to(:creditor).with_foreign_key('creditor_id') }
    # it { is_expected.to belong_to(:event) }
  end

  describe 'インスタンスメソッド' do
    let(:completed_transaction) { create(:event_transaction) }
    let(:uncompleted_transaction) { create(:event_transaction, :uncompleted) }
    let(:overpaid_transaction) { create(:event_transaction) }

    context 'to_param' do
      it 'url_tokenを返す' do
        expect(completed_transaction.to_param).to eq completed_transaction.url_token
      end
    end

    context 'completed?' do
      it 'completedなときtrueを返す' do
        expect(completed_transaction.completed?).to be_truthy
      end
      it 'uncompletedなときfalseを返す' do
        expect(uncompleted_transaction.completed?).to be_falsey
      end
      it 'overpaidなときfalseを返す' do
        overpaid_transaction.update_attribute(:payment, 10000)
        expect(overpaid_transaction.completed?).to be_falsey
      end
    end

    context 'uncompleted?' do
      it 'completedなときfalseを返す' do
        expect(completed_transaction.uncompleted?).to be_falsey
      end
      it 'uncompletedなときtrueを返す' do
        expect(uncompleted_transaction.uncompleted?).to be_truthy
      end
      it 'overpaidなときfalseを返す' do
        overpaid_transaction.update_attribute(:payment, 10000)
        expect(overpaid_transaction.uncompleted?).to be_falsey
      end
    end

    context 'overpayment?' do
      it 'completedなときfalseを返す' do
        expect(completed_transaction.overpayment?).to be_falsey
      end
      it 'uncompletedなときfalseを返す' do
        expect(uncompleted_transaction.overpayment?).to be_falsey
      end
      it 'overpaidなときtrueを返す' do
        overpaid_transaction.update_attribute(:payment, 10000)
        expect(overpaid_transaction.overpayment?).to be_truthy
      end
    end


  end
end
