# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:today) { Time.current.midnight }
  it 'イベントは有効なファクトリを持つこと' do
    expect(build(:event)).to be_valid
  end

  describe 'バリデーション' do
    context 'イベント名に関して' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(128) }
    end

    context '開始日に関して' do
      it '開始日がなければ無効であること' do
        event = build(:event, start_date: nil)
        event.valid?
        expect(event.errors[:start_date]).to include('は今日以降のものを選択してください')
      end
      it '今日であるのは有効であること' do
        event = build(:event, start_date: today, answer_deadline: today)
        expect(event).to be_valid
      end
      it '今日以前だと無効であること' do
        event = build(:event, start_date: today.ago(3.days), answer_deadline: today)
        event.valid?
        expect(event.errors[:start_date]).to include('は今日以降のものを選択してください')
      end
    end

    context '終了日に関して' do
      it '終了日がなければ無効であること' do
        event = build(:event, end_date: nil)
        event.valid?
        expect(event.errors[:end_date]).to include('は開始日以降のものを選択してください')
      end
      it '今日であるのは有効であること' do
        event = build(:event, start_date: today, end_date: today, answer_deadline: today)
        expect(event).to be_valid
      end
      it '今日以前だと無効であること' do
        event = build(:event, end_date: today.ago(3.days))
        event.valid?
        expect(event.errors[:end_date]).to include('は開始日以降のものを選択してください')
      end
      it '開始日以前だと無効であること' do
        event = build(:event, answer_deadline: today.since(5.days), end_date: today.since(3.days))
        event.valid?
        expect(event.errors[:end_date]).to include('は開始日以降のものを選択してください')
      end
    end

    context '回答締切日に関して' do
      it '回答締切日がなければ無効であること' do
        event = build(:event, answer_deadline: nil)
        event.valid?
        expect(event.errors[:answer_deadline]).to include('は今日以降のものを選択してください')
      end
      it '今日であるのは有効であること' do
        event = build(:event, answer_deadline: today)
        expect(event).to be_valid
      end
      it '今日以前だと無効であること' do
        event = build(:event, answer_deadline: today.ago(3.days))
        event.valid?
        expect(event.errors[:answer_deadline]).to include('は今日以降のものを選択してください')
      end
      it '開始日以後だと無効であること' do
        event = build(:event, answer_deadline: today.since(5.days), start_date: today.since(3.days))
        event.valid?
        expect(event.errors[:answer_deadline]).to include('は開始日以前のものを選択してください')
      end
    end

    context '詳細に関して' do
      it { is_expected.to validate_length_of(:description).is_at_most(2048) }
    end

    context 'ひとことに関して' do
      it { is_expected.to validate_length_of(:comment).is_at_most(40) }
    end
  end

  describe '関連付け' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:transactions) }
    it { is_expected.to have_many(:answers) }
    it { is_expected.to have_many(:users).through(:answers) }
    it { is_expected.to have_many(:fees) }
  end

  describe 'クラスメソッド' do
    let!(:user) { create(:user) }
    let!(:group1) { create(:group) }
    let!(:group2) { create(:group) }
    let!(:group3) { create(:group) }
    let!(:group_user1) { create(:group_user, group_id: group1.id, user_id: user.id) }
    let!(:group_user2) { create(:group_user, group_id: group2.id, user_id: user.id) }
    let!(:event1) { create(:event, group_id: group1.id) }
    let!(:event2) { create(:event, group_id: group1.id) }
    let!(:event3) { create(:event, group_id: group2.id) }
    let!(:event4) { create(:event, group_id: group3.id) }

    context 'my_groups_events' do
      it '自分の所属するサークルのイベントを返す' do
        expect(Event.my_groups_events(user)).to eq [event1, event2, event3]
      end
      it '自分の所属しないサークルのイベントを返さない' do
        expect(Event.my_groups_events(user)).to_not include event4
      end
    end

    context 'my_attending_events' do
      let!(:answer1) { create(:answer, event_id: event1.id, user_id: user.id) }
      let!(:answer2) { create(:answer, :absent, event_id: event2.id, user_id: user.id) }
      let!(:answer3) { create(:answer, event_id: event3.id, user_id: user.id) }

      it '自分の参加するイベントを返す' do
        expect(Event.my_attending_events(user)).to eq [event1, event3]
      end

      it '自分の参加しないイベントを返さない' do
        expect(Event.my_attending_events(user)).to_not include event2
      end

      it '自分の所属しないサークルのイベントは返さない' do
        expect(Event.my_attending_events(user)).to_not include event4
      end
    end
  end
end
