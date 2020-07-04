# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event::Transaction, type: :model do
  describe 'バリデーション' do
    context 'event_idに関して' do
      let!(:debtor) { create(:user) }
      let!(:event) { create(:event) }
      let!(:other_event) { create(:event) }
      let!(:event_transaction) { create(:event_transaction, debtor_id: debtor.id, event_id: event.id) }
      it 'debtor_idとユニークであること' do
        after_event_transaction = build(:event_transaction, debtor_id: debtor.id, event_id: other_event.id)
        expect(after_event_transaction).to be_valid
      end
      it 'debtor_idと重複したら無効であること' do
        after_event_transaction = build(:event_transaction, debtor_id: debtor.id, event_id: event.id)
        after_event_transaction.valid?
        expect(after_event_transaction.errors[:event_id]).to include('は既に使用されています。')
      end
    end
  end

  describe '関連付け' do
    it { is_expected.to belong_to(:event) }
  end
end
