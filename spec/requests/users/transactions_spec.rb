# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Transactions', type: :request do
  let(:member) { create(:user) }
  let(:member2) { create(:user) }
  let(:group) { create(:group) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }
  let!(:member_relationship2) { create(:group_user, user_id: member2.id, group_id: group.id) }

  describe 'GET #lend(貸しメモ)' do
    context '認証済みのユーザーとして' do
      context '他人なら' do
        it '正常なレスポンスを返すこと' do
          sign_in member
          get lend_user_transactions_path(user_id: member2.id)
          expect(response).to have_http_status '200'
        end
      end

      context '自分なら' do
        it 'ホーム画面にリダイレクトすること' do
          sign_in member
          get lend_user_transactions_path(user_id: member.id)
          expect(response).to redirect_to '/home'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get lend_user_transactions_path(user_id: member2.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get lend_user_transactions_path(user_id: member2.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'GET #borrow(貸しメモ)' do
    context '認証済みのユーザーとして' do
      context '他人なら' do
        it '正常なレスポンスを返すこと' do
          sign_in member
          get borrow_user_transactions_path(user_id: member2.id)
          expect(response).to have_http_status '200'
        end
      end

      context '自分なら' do
        it 'ホーム画面にリダイレクトすること' do
          sign_in member
          get borrow_user_transactions_path(user_id: member.id)
          expect(response).to redirect_to '/home'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get borrow_user_transactions_path(user_id: member2.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get borrow_user_transactions_path(user_id: member2.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'POST #create(貸し借り作成)' do
    context '認証済みのユーザーとして' do
      context '他のメンバーへ/からなら' do
        context '有効な属性値の場合' do
          it '貸しメモが作成されること' do
            transaction_params = attributes_for(:individual_transaction, creditor_id: member.id, debtor_id: member2.id)
            sign_in member
            expect do
              post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
            end.to change(Individual::Transaction, :count).by(1)
          end

          it '借りメモが作成されること' do
            transaction_params = attributes_for(:individual_transaction, creditor_id: member2.id, debtor_id: member.id)
            sign_in member
            expect do
              post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
            end.to change(Individual::Transaction, :count).by(1)
          end

          it '貸しメモを作成するとMy収支にリダイレクトされること' do
            transaction_params = attributes_for(:individual_transaction, creditor_id: member.id, debtor_id: member2.id)
            sign_in member
            post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
            expect(response).to redirect_to "/users/#{member.id}/transactions"
          end

          it '借りメモを作成するとMy収支にリダイレクトされること' do
            transaction_params = attributes_for(:individual_transaction, creditor_id: member2.id, debtor_id: member.id)
            sign_in member
            post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
            expect(response).to redirect_to "/users/#{member.id}/transactions"
          end
        end

        context '無効な属性値の場合' do
          it '貸し借りメモが作成されないこと' do
            transaction_params = attributes_for(:individual_transaction, :invalid)
            sign_in member
            expect do
              post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
            end.to change(group.events, :count).by(0)
          end
        end
      end

      context '自分に貸し借りメモを作成すると' do
        it '貸しメモが作成されないこと' do
          transaction_params = attributes_for(:individual_transaction, creditor_id: member.id, debtor_id: member2.id)
          sign_in member
          expect do
            post user_transactions_path(user_id: member.id), params: { individual_transaction: transaction_params }
          end.to change(Individual::Transaction, :count).by(0)
        end

        it '借りメモが作成されないこと' do
          transaction_params = attributes_for(:individual_transaction, creditor_id: member2.id, debtor_id: member.id)
          sign_in member
          expect do
            post user_transactions_path(user_id: member.id), params: { individual_transaction: transaction_params }
          end.to change(Individual::Transaction, :count).by(0)
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        transaction_params = attributes_for(:individual_transaction, creditor_id: member.id, debtor_id: member2.id)
        post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        transaction_params = attributes_for(:individual_transaction, creditor_id: member.id, debtor_id: member2.id)
        post user_transactions_path(user_id: member2.id), params: { individual_transaction: transaction_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:lending_transaction) { create(:individual_transaction, :uncompleted, creditor_id: member.id, debtor_id: member2.id) }
  let(:borrowing_transaction) { create(:individual_transaction, :uncompleted, creditor_id: member2.id, debtor_id: member.id) }

  describe 'GET #edit(貸し借りメモ編集ページ)' do
    context '認証済みのユーザーとして' do
      context '貸しメモを編集時' do
        it '正常なレスポンスを返すこと' do
          sign_in member
          get edit_users_transaction_path(url_token: lending_transaction.url_token)
          expect(response).to have_http_status '200'
        end
      end

      context '借りメモを編集時' do
        it '正常なレスポンスを返すこと' do
          sign_in member
          get edit_users_transaction_path(url_token: borrowing_transaction.url_token)
          expect(response).to have_http_status '200'
        end
      end
    end

    context 'ゲストとして' do
      context '貸しメモを編集時' do
        it '302レスポンスを返すこと' do
          get edit_users_transaction_path(url_token: lending_transaction.url_token)
          expect(response).to have_http_status '302'
        end

        it 'サインイン画面にリダイレクトすること' do
          get edit_users_transaction_path(url_token: lending_transaction.url_token)
          expect(response).to redirect_to '/users/sign_in'
        end
      end

      context '借りメモを編集時' do
        it '借りメモを編集時、302レスポンスを返すこと' do
          get edit_users_transaction_path(url_token: borrowing_transaction.url_token)
          expect(response).to have_http_status '302'
        end

        it '借りメモを編集時、サインイン画面にリダイレクトすること' do
          get edit_users_transaction_path(url_token: borrowing_transaction.url_token)
          expect(response).to redirect_to '/users/sign_in'
        end
      end
    end
  end

  describe 'GET #update(貸し借りメモ編集)' do
    context '認証済みのユーザーとして' do
      context '有効な属性値の場合' do
        it '貸しメモが編集されること' do
          transaction_params = attributes_for(:individual_transaction, payment: 3000)
          sign_in member
          patch users_transaction_path(url_token: lending_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(lending_transaction.reload.payment).to eq 3000
        end

        it '借りメモが編集されること' do
          transaction_params = attributes_for(:individual_transaction, payment: 3000)
          sign_in member
          patch users_transaction_path(url_token: borrowing_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(borrowing_transaction.reload.payment).to eq 3000
        end
      end

      context '無効な属性値の場合' do
        it '貸しメモが編集されないこと' do
          transaction_params = attributes_for(:individual_transaction, :invalid)
          sign_in member
          patch users_transaction_path(url_token: lending_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(lending_transaction.reload.payment).to eq 0
        end

        it '借りメモが編集されないこと' do
          transaction_params = attributes_for(:individual_transaction, :invalid)
          sign_in member
          patch users_transaction_path(url_token: borrowing_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(borrowing_transaction.reload.payment).to eq 0
        end
      end
    end

    context 'ゲストとして' do
      context '貸しメモを編集時' do
        it '302レスポンスを返すこと' do
          transaction_params = attributes_for(:individual_transaction, payment: 3000)
          patch users_transaction_path(url_token: lending_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(response).to have_http_status '302'
        end

        it 'サインイン画面にリダイレクトすること' do
          transaction_params = attributes_for(:individual_transaction, payment: 3000)
          patch users_transaction_path(url_token: lending_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(response).to redirect_to '/users/sign_in'
        end
      end

      context '借りメモを編集時' do
        it '302レスポンスを返すこと' do
          transaction_params = attributes_for(:individual_transaction, payment: 3000)
          patch users_transaction_path(url_token: borrowing_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(response).to have_http_status '302'
        end

        it 'サインイン画面にリダイレクトすること' do
          transaction_params = attributes_for(:individual_transaction, payment: 3000)
          patch users_transaction_path(url_token: borrowing_transaction.url_token), params: { individual_transaction: transaction_params }
          expect(response).to redirect_to '/users/sign_in'
        end
      end
    end
  end
end
