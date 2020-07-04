require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  let(:executive) { create(:user) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:group) { create(:group) }
  let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }

  describe "GET #index(My収支ページ)" do
    context '認証済みのユーザーとして' do
      context '自分なら' do
        it '正常なレスポンスを返すこと' do
          sign_in member
          get user_transactions_path(user_id: member.id)
          expect(response).to have_http_status '200'
        end
      end

      context '他人なら' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get user_transactions_path(user_id: member.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get user_transactions_path(user_id: member.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get user_transactions_path(user_id: member.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:event) { create(:event, group_id: group.id) }
  let(:event_transaction) { create(:event_transaction, :uncompleted, event_id: event.id) }

  describe "GET #change(非同期イベント収支完了)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it 'イベント収支が完了すること' do
          sign_in executive
          patch change_transaction_path(url_token: event_transaction.url_token),
                                        params: { url_token: event_transaction.url_token, payment: event_transaction.debt }
          expect(event_transaction.reload.debt).to eq event_transaction.reload.payment
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          patch change_transaction_path(url_token: event_transaction.url_token),
                                        params: { url_token: event_transaction.url_token, payment: event_transaction.debt }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          patch change_transaction_path(url_token: event_transaction.url_token),
                                        params: { url_token: event_transaction.url_token, payment: event_transaction.debt }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        patch change_transaction_path(url_token: event_transaction.url_token),
                                        params: { url_token: event_transaction.url_token, payment: event_transaction.debt }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        patch change_transaction_path(url_token: event_transaction.url_token),
                                        params: { url_token: event_transaction.url_token, payment: event_transaction.debt }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
