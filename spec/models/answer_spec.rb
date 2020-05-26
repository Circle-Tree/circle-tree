require 'rails_helper'

RSpec.describe Answer, type: :model do
  it '回答は有効なファクトリを持つこと' do
    expect(build(:answer)).to be_valid
  end

  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    context '回答状況に関して' do
      it { is_expected.to validate_presence_of(:status) }
      it { is_expected.to define_enum_for(:status).with_values(
        unanswered: 10,
        attending: 20,
        absent: 30
      ) }
    end

    it 'ユーザーとイベントはユニークであること' do
      create(:answer, user_id: user.id, event_id: event.id)
      answer = build(:answer, user_id: user.id, event_id: event.id)
      answer.valid?
      expect(answer.errors[:event_id]).to include('は既に使用されています。')
    end

    context '出欠理由に関して' do
      it { is_expected.to define_enum_for(:reason).with_values(
        nothing: 0,
        job: 1,
        friend: 2,
        family: 3,
        money: 4,
        unfavorable: 5,
        other: 6
      ) }
    end
  end

  describe '関連付け' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end
end
