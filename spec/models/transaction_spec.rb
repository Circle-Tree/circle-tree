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

  # describe 'クラスメソッド' do
  #   let(:user) { create(:user) }
  #   let(:event1) { create(:event) }
  #   let(:event2) { create(:event) }
  #   let(:event3) { create(:event) }
  #   let(:event4) { create(:event) }
  #   let(:event5) { create(:event) }
  #   let(:event6) { create(:event) }
  #   let!(:answer1) { create(:answer, event_id: event1.id, user_id: user.id) }
  #   let!(:answer2) { create(:answer, event_id: event2.id, user_id: user.id) }
  #   let!(:answer3) { create(:answer, event_id: event3.id, user_id: user.id) }
  #   let!(:answer4) { create(:answer, :absent, event_id: event4.id, user_id: user.id) }
  #   let!(:answer5) { create(:answer, :unanswered, event_id: event5.id, user_id: user.id) }
  #   let!(:event_transaction1) { create(:event_transaction, event_id: event1.id, debtor_id: user.id) }
  #   let!(:event_transaction2) { create(:event_transaction, event_id: event2.id, debtor_id: user.id) }
  #   let!(:event_transaction3) { create(:event_transaction, event_id: event3.id, debtor_id: user.id) }
  #   let!(:event_transaction4) { create(:event_transaction, event_id: event4.id, debtor_id: user.id) }
  #   let!(:event_transaction5) { create(:event_transaction, event_id: event5.id, debtor_id: user.id) }

  #   context 'transactions_for_attending_event_by_user' do
  #     it '回答済みイベントのTransactionを返す' do
  #       id = event_transaction1.id
  #       expect(Transaction.transactions_for_attending_event_by_user(user)).to eq Event::Transaction.where(id: [id, id+1, id+2])
  #     end
  #   end

  #   context 'uncompleted_transactions_by_user' do
  #     it 'uncompletedなTransactionを返す' do
  #       event_transaction3.update_attribute(:payment, 0)
  #       event_transaction4.update_attribute(:payment, 0)
  #       id = event_transaction1.id
  #       transactions = Transaction.where(id: [id, id+1, id+2, id+3, id+4])
  #       expect(
  #         Transaction.uncompleted_transactions_by_user(transactions)
  #       ).to eq [event_transaction3, event_transaction4]
  #     end
  #   end

  #   context 'overdue_transactions_by_user' do
  #     it 'overdueなTransactionを返す' do
  #       id = event_transaction1.id
  #       transactions = Transaction.where(id: [id, id+1, id+2, id+3, id+4])
  #       uncompleted_transactions = Transaction.uncompleted_transactions_by_user(transactions)
  #       event_transaction3.update_attribute(:deadline, Time.current.midnight.ago(3.days))
  #       expect(uncompleted_transactions).to include event_transaction3
  #       expect(uncompleted_transactions).to_not include event_transaction4
  #     end
  #   end

  #   context 'urgent_transactions_by_user' do
  #     it 'urgentなTransactionを返す' do
  #       id = event_transaction1.id
  #       transactions = Transaction.where(id: [id, id+1])
  #       event_transaction1.update_attribute(:deadline, Time.current.midnight.since(2.days))
  #       expect(transactions).to include event_transaction1
  #       expect(transactions).to_not include event_transaction2
  #     end
  #   end
  # end
end
