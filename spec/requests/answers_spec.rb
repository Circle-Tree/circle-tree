require 'rails_helper'

RSpec.describe "Answers", type: :request do
  # let(:executive) { create(:user) }
  # let(:member) { create(:user) }
  # let(:other_member) { create(:user) }
  # let(:group) { create(:group) }
  # let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  # let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }
  # let(:event) { create(:event, group_id: group.id) }
  # let(:answer) { create(:answer, event_id: event.id, user_id: member.id) }

  # describe "POST #create(回答作成)" do
  #   context '認証済みのユーザーとして' do
  #     context 'そのサークルのメンバーなら' do
  #       context '有効な属性値の場合' do
  #         it '回答が作成されること' do
  #           answer_params = attributes_for(:answer, event_id: event.id, user_id: member.id)
  #           sign_in member
  #           expect do
  #             post event_answers_path(event_id: event.id), params: { answer: answer_params }
  #           end.to change(event.answers, :count).by(1)
  #         end

  #         it '#details(メンバー用イベント詳細)にリダイレクトされること' do
  #           answer_params = attributes_for(:answer, event_id: event.id, user_id: member.id)
  #           sign_in member
  #           post event_answers_path(event_id: event.id), params: { answer: answer_params }
  #           expect(response).to redirect_to "/groups/#{group.id}/events/#{event.id}/details"
  #         end
  #       end

  #       context '無効な属性値の場合' do
  #         it '回答が作成されないこと' do
  #           answer_params = attributes_for(:answer, :invalid)
  #           sign_in member
  #           expect do
  #             post event_answers_path(event_id: event.id), params: { answer: answer_params }
  #           end.to change(group.events, :count).by(0)
  #         end
  #       end
  #     end

  #     context '外部のメンバーとして' do
  #       it '403レスポンスを返すこと' do
  #         answer_params = attributes_for(:answer, event_id: event.id, user_id: member.id)
  #         sign_in other_member
  #         post event_answers_path(event_id: event.id), params: { answer: answer_params }
  #         expect(response).to have_http_status '403'
  #       end
  #     end
  #   end

  #   context 'ゲストとして' do
  #     it '302レスポンスを返すこと' do
  #       answer_params = attributes_for(:answer, event_id: event.id, user_id: member.id)
  #       post event_answers_path(event_id: event.id), params: { answer: answer_params }
  #       expect(response).to have_http_status '302'
  #     end

  #     it 'サインイン画面にリダイレクトすること' do
  #       answer_params = attributes_for(:answer, event_id: event.id, user_id: member.id)
  #       post event_answers_path(event_id: event.id), params: { answer: answer_params }
  #       expect(response).to redirect_to '/users/sign_in'
  #     end
  #   end
  # end
end
