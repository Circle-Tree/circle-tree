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

  describe 'クラスメソッド' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:user4) { create(:user) }
    let!(:user5) { create(:user) }
    let!(:user6) { create(:user) }
    let!(:user7) { create(:user) }
    let!(:user8) { create(:user) }
    let!(:user9) { create(:user) }
    let!(:event) { create(:event) }
    let!(:answer1) { create(:answer, event_id: event.id, user_id: user1.id) }
    let!(:answer2) { create(:answer, event_id: event.id, user_id: user2.id) }
    let!(:answer3) { create(:answer, event_id: event.id, user_id: user3.id) }
    let!(:answer4) { create(:answer, event_id: event.id, user_id: user4.id) }
    let!(:answer5) { create(:answer, :absent, event_id: event.id, user_id: user5.id) }
    let!(:answer6) { create(:answer, :absent, event_id: event.id, user_id: user6.id) }
    let!(:answer7) { create(:answer, :absent, event_id: event.id, user_id: user7.id) }
    let!(:answer8) { create(:answer, :unanswered, event_id: event.id, user_id: user8.id) }
    let!(:answer9) { create(:answer, :unanswered, event_id: event.id, user_id: user9.id) }

    context 'divide_answers_in_three' do
      it 'attendingの回答を返す' do
        expect(Answer.divide_answers_in_three(event)[:attending]).to eq [answer1, answer2, answer3, answer4]
      end
      it 'absentの回答を返す' do
        expect(Answer.divide_answers_in_three(event)[:absent]).to eq [answer5, answer6, answer7]
      end
      it 'unansweredの回答を返す' do
        expect(Answer.divide_answers_in_three(event)[:unanswered]).to eq [answer8, answer9]
      end
    end

    context 'attending_count' do
      it 'attendingの回答の数を返す' do
        expect(Answer.attending_count(event: event)).to eq 4
      end
    end

    context 'absent_count' do
      it 'absentの回答の数を返す' do
        expect(Answer.absent_count(event: event)).to eq 3
      end
    end

    context 'unanswered_count' do
      it 'unansweredの回答の数を返す' do
        expect(Answer.unanswered_count(event: event)).to eq 2
      end
    end

    context 'new_answer_when_create_new_event' do
      let(:event2) { create(:event) }

      it 'イベント作成時に回答を作成する' do
        expect {
          Answer.new_answer_when_create_new_event(user: user1, event: event2)
        }.to change(event2.answers, :count).by(1)
      end

      it 'イベント作成時にunansweredの回答を作成する' do
        Answer.new_answer_when_create_new_event(user: user2, event: event2)
        answer10 = Answer.last
        expect(answer10.status).to eq 'unanswered'
        expect(answer10.event_id).to eq event2.id
        expect(answer10.user_id).to eq user2.id
      end
    end
  end
end
