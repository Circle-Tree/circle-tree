# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events::Transactions', type: :request do
  let(:executive) { create(:user) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:group) { create(:group) }
  let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }
  let(:event) { create(:event, group_id: group.id) }
  let(:event_transaction) { create(:event_transaction, :uncompleted, event_id: event.id) }

  describe 'GET #edit(イベント収支編集ページ)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get edit_event_transaction_path(event_id: event.id, url_token: event_transaction.url_token)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get edit_event_transaction_path(event_id: event.id, url_token: event_transaction.url_token)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get edit_event_transaction_path(event_id: event.id, url_token: event_transaction.url_token)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get edit_event_transaction_path(event_id: event.id, url_token: event_transaction.url_token)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get edit_event_transaction_path(event_id: event.id, url_token: event_transaction.url_token)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'PATCH #update(イベント収支編集)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        context '有効な属性値なら' do
          it 'イベント収支が編集されること' do
            transaction_params = attributes_for(:event_transaction, payment: 3000)
            sign_in executive
            patch event_transaction_path(event_id: event.id, url_token: event_transaction.url_token), params: { event_transaction: transaction_params }
            expect(event_transaction.reload.payment).to eq 3000
          end
        end

        context '無効な属性値なら' do
          it 'イベント収支が編集されないこと' do
            transaction_params = attributes_for(:event_transaction, :invalid)
            sign_in executive
            patch event_transaction_path(event_id: event.id, url_token: event_transaction.url_token), params: { event_transaction: transaction_params }
            expect(event_transaction.reload.debt).to eq 5000
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          transaction_params = attributes_for(:event, payment: 3000)
          sign_in member
          patch event_transaction_path(event_id: event.id, url_token: event_transaction.url_token), params: { event_transaction: transaction_params }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          transaction_params = attributes_for(:event, payment: 3000)
          sign_in other_member
          patch event_transaction_path(event_id: event.id, url_token: event_transaction.url_token), params: { event_transaction: transaction_params }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        transaction_params = attributes_for(:event, payment: 3000)
        patch event_transaction_path(event_id: event.id, url_token: event_transaction.url_token), params: { event_transaction: transaction_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        transaction_params = attributes_for(:event, payment: 3000)
        patch event_transaction_path(event_id: event.id, url_token: event_transaction.url_token), params: { event_transaction: transaction_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
