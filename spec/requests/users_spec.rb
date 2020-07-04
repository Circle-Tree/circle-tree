# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET #index(メンバー一覧)' do
    let(:group) { create(:group) }

    context '認証済みのユーザーとして' do
      let(:member) { create(:user) }
      let(:other_member) { create(:user) }
      let!(:group_user1) { create(:group_user, user_id: member.id, group_id: group.id) }

      context 'メンバーとして' do
        it '正常なレスポンスを返すこと' do
          sign_in member
          get group_users_path(group_id: group.id)
          expect(response).to have_http_status '200'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get group_users_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get group_users_path(group_id: group.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get group_users_path(group_id: group.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'GET #join(サークル入会)' do
    let(:user) { create(:user) }

    context '認証済みのユーザーとして' do
      it '正常なレスポンスを返すこと' do
        sign_in user
        get join_users_path
        expect(response).to have_http_status '200'
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get join_users_path
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get join_users_path
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'GET #leave(サークル退会)' do
    let(:user) { create(:user) }

    context '認証済みのユーザーとして' do
      it '正常なレスポンスを返すこと' do
        sign_in user
        get leave_users_path
        expect(response).to have_http_status '200'
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get leave_users_path
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get leave_users_path
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'GET #withdraw(サービス退会)' do
    let(:user) { create(:user) }

    context '認証済みのユーザーとして' do
      it '正常なレスポンスを返すこと' do
        sign_in user
        get withdraw_users_path
        expect(response).to have_http_status '200'
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get withdraw_users_path
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get withdraw_users_path
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  # 後程実装
  # describe "GET #batch(一括登録)" do
  # end
end
