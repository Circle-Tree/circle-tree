# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups', type: :request do
  let(:user) { create(:user) }

  describe 'GET #new(サークル作成ページ)' do
    context '認証済みのユーザーとして' do
      it '正常なレスポンスを返すこと' do
        sign_in user
        get new_group_path
        expect(response).to have_http_status '200'
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get new_group_path
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get new_group_path
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'POST #create(サークル作成)' do
    context '認証済みのユーザーとして' do
      context '有効な属性値の場合' do
        it 'サークルが作成されること' do
          group_params = attributes_for(:group)
          sign_in user
          expect do
            post groups_path, params: { group: group_params }
          end.to change(Group, :count).by(1)
        end

        it 'ホームにリダイレクトされること' do
          group_params = attributes_for(:group)
          sign_in user
          post groups_path, params: { group: group_params }
          expect(response).to redirect_to '/home'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        group_params = attributes_for(:group)
        post groups_path, params: { group: group_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        group_params = attributes_for(:group)
        post groups_path, params: { group: group_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:executive) { create(:user) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:group) { create(:group) }
  let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }
  let!(:executive_relationship2) { create(:group_user, :executive, group_id: group.id) }

  describe 'GET #edit(サークル編集ページ)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get edit_group_path(id: group.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get edit_group_path(id: group.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get edit_group_path(id: group.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get edit_group_path(id: group.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get edit_group_path(id: group.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'PATCH #update(サークル編集)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        context '有効な属性値の場合' do
          it 'サークルが編集されること' do
            group_params = attributes_for(:group, name: 'after_group')
            sign_in executive
            patch group_path(id: group.id), params: { group: group_params }
            expect(group.reload.name).to eq 'after_group'
          end

          it '編集ページにリダイレクトされること' do
            group_params = attributes_for(:group, name: 'after_group')
            sign_in executive
            patch group_path(id: group.id), params: { group: group_params }
            expect(response).to redirect_to "/groups/#{group.id}/edit"
          end
        end

        context '無効な属性値の場合' do
          it 'サークルが編集されないこと' do
            group_params = attributes_for(:group, :invalid)
            sign_in executive
            patch group_path(id: group.id), params: { group: group_params }
            expect(group.reload.name).to eq group.name
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          group_params = attributes_for(:group, :invalid)
          sign_in member
          patch group_path(id: group.id), params: { group: group_params }
          get edit_group_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          group_params = attributes_for(:group, :invalid)
          sign_in other_member
          patch group_path(id: group.id), params: { group: group_params }
          get edit_group_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        group_params = attributes_for(:group, name: 'after_group')
        patch group_path(id: group.id), params: { group: group_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        group_params = attributes_for(:group, name: 'after_group')
        patch group_path(id: group.id), params: { group: group_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'PATCH #change(メンバー設定' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get change_group_path(id: group.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get change_group_path(id: group.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get change_group_path(id: group.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get change_group_path(id: group.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get change_group_path(id: group.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:new_executive) { create(:user) }
  let!(:new_executive_relationship) { create(:group_user, user_id: new_executive.id, group_id: group.id) }

  describe 'POST #inherit(引継ぎ)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '有効な属性値な場合' do
          sign_in executive
          post inherit_group_path(id: group.id), params: { new_executive: new_executive.id }
          expect(executive_relationship.reload.role).to eq 'general'
          expect(new_executive_relationship.reload.role).to eq 'executive'
        end
      end
    end

    context 'そのサークルの一般人なら' do
      it '403レスポンスを返すこと' do
        sign_in member
        post inherit_group_path(id: group.id), params: { new_executive: new_executive.id }
        expect(response).to have_http_status '403'
      end
    end

    context '外部のメンバーとして' do
      it '403レスポンスを返すこと' do
        sign_in other_member
        post inherit_group_path(id: group.id), params: { new_executive: new_executive.id }
        expect(response).to have_http_status '403'
      end
    end
  end

  describe 'POST #assign(任命)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '有効な属性値な場合' do
          sign_in executive
          post assign_group_path(id: group.id), params: { new_executive: new_executive.id }
          expect(executive_relationship.reload.role).to eq 'executive'
          expect(new_executive_relationship.reload.role).to eq 'executive'
        end
      end
    end

    context 'そのサークルの一般人なら' do
      it '403レスポンスを返すこと' do
        sign_in member
        post assign_group_path(id: group.id), params: { new_executive: new_executive.id }
        expect(response).to have_http_status '403'
      end
    end

    context '外部のメンバーとして' do
      it '403レスポンスを返すこと' do
        sign_in other_member
        post assign_group_path(id: group.id), params: { new_executive: new_executive.id }
        expect(response).to have_http_status '403'
      end
    end
  end

  # GETからPATCHに変えたい
  describe 'GET #resign(辞退)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '有効な属性値な場合' do
          sign_in executive
          get resign_group_path(id: group.id)
          expect(executive_relationship.reload.role).to eq 'general'
        end
      end
    end

    context 'そのサークルの一般人なら' do
      it '403レスポンスを返すこと' do
        sign_in member
        get resign_group_path(id: group.id)
        expect(response).to have_http_status '403'
      end
    end

    context '外部のメンバーとして' do
      it '403レスポンスを返すこと' do
        sign_in other_member
        get resign_group_path(id: group.id)
        expect(response).to have_http_status '403'
      end
    end
  end

  # describe "GET #deposit(デポジット)" do
  # end

  # describe "GET #statistics(統計)" do
  # end
end
