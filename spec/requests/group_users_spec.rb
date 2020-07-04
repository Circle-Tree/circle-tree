require 'rails_helper'

RSpec.describe "GroupUsers", type: :request do
  let(:executive) { create(:user) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:group) { create(:group) }
  let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }
  let(:event) { create(:event) }

  describe "GET #invite(招待)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it 'メンバーを増えること' do
          sign_in executive
          expect do
            post invite_group_group_users_path(group_id: group.id), params: { email: other_member.email }
          end.to change(group.group_users, :count).by(1)
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          post invite_group_group_users_path(group_id: group.id), params: { email: other_member.email }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          post invite_group_group_users_path(group_id: group.id), params: { email: other_member.email }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        post invite_group_group_users_path(group_id: group.id), params: { email: other_member.email }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        post invite_group_group_users_path(group_id: group.id), params: { email: other_member.email }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "POST #join(サークルに参加)" do
    context '認証済みのユーザーとして' do
      context '外部のメンバーとして' do
        it 'メンバーが増えること' do
          sign_in other_member
          expect do
            post join_group_users_path, params: { group_number: group.group_number, user_id: other_member.id }
          end.to change(group.group_users, :count).by(1)
        end

        it '増えたメンバーは一般人であること' do
          sign_in other_member
          post join_group_users_path, params: { group_number: group.group_number, user_id: other_member.id }
          expect(GroupUser.last.role).to eq 'general'
        end

        it 'ホーム画面にリダイレクトすること' do
          sign_in other_member
          post join_group_users_path, params: { group_number: group.group_number, user_id: other_member.id }
          expect(response).to redirect_to '/home'
        end
      end

      context 'そのサークルのメンバーなら' do
        it 'メンバーが増えないこと' do
          sign_in member
          expect do
            post join_group_users_path, params: { group_number: group.group_number, user_id: member.id }
          end.to change(group.group_users, :count).by(0)
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        post join_group_users_path, params: { group_number: group.group_number, user_id: other_member.id }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        post join_group_users_path, params: { group_number: group.group_number, user_id: other_member.id }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "DELETE #leave(サークルを退会)" do
    context '認証済みのユーザーとして' do
      context '一般人として' do
        it '退会すること' do
          group_user_params = attributes_for(:group_user, group_id: group.id, user_id: member.id)
          sign_in member
          expect do
            delete leave_group_users_path, params: { group_user: group_user_params }
          end.to change(group.group_users, :count).by(-1)
        end

        it 'ホーム画面にリダイレクトすること' do
          group_user_params = attributes_for(:group_user, group_id: group.id, user_id: member.id)
          sign_in member
          delete leave_group_users_path, params: { group_user: group_user_params }
          expect(response).to redirect_to '/home'
        end
      end

      context 'そのサークルの幹事なら' do
        it 'メンバーが増えないこと' do
          group_user_params = attributes_for(:group_user, group_id: group.id, user_id: executive.id)
          sign_in executive
          expect do
            delete leave_group_users_path, params: { group_user: group_user_params }
          end.to change(group.group_users, :count).by(0)
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        group_user_params = attributes_for(:group_user, group_id: group.id, user_id: member.id)
        delete leave_group_users_path, params: { group_user: group_user_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        group_user_params = attributes_for(:group_user, group_id: group.id, user_id: member.id)
        delete leave_group_users_path, params: { group_user: group_user_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:executive2) { create(:user) }
  let(:executive_relationship2) { create(:group_user, :executive, user_id: executive2.id, group_id: group.id) }
  let(:member3) { create(:user) }
  let(:member_relationship2) { create(:group_user, user_id: member3.id, group_id: group.id) }

  describe "DELETE #destroy(サークルからメンバーを退会させる)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事として' do
        # it '一般人を退会させること' do
        #   sign_in executive
        #   expect do
        #     delete group_user_path(id: member_relationship2.id)
        #   end.to change(group.group_users, :count).by(-1)
        # end

        it 'ホーム画面にリダイレクトすること' do
          sign_in executive
          delete group_user_path(id: member_relationship2.id)
          expect(response).to redirect_to "/groups/#{group.id}/users"
        end

        it '幹事を退会させられないこと' do
          sign_in executive
          expect do
            delete group_user_path(id: executive_relationship2.id)
          end.to change(group.group_users, :count).by(0)
        end
      end

      # context 'そのサークルの一般人として' do
      #   it '403レスポンスを返すこと' do
      #     sign_in member
      #     delete group_user_path(id: member_relationship2.id)
      #     expect(response).to have_http_status '403'
      #   end
      # end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        delete group_user_path(id: member_relationship2.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        delete group_user_path(id: member_relationship2.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
