require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:executive) { create(:user) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:group) { create(:group) }
  let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }

  describe "GET #index(幹事用イベント一覧)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get group_events_path(group_id: group.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get group_events_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get group_events_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get group_events_path(group_id: group.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get group_events_path(group_id: group.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "GET #list(幹事＆一般人用イベント一覧)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get list_user_events_path(user_id: executive.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '200レスポンスを返すこと' do
          sign_in member
          get list_user_events_path(user_id: member.id)
          expect(response).to have_http_status '200'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get list_user_events_path(user_id:member.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get group_events_path(group_id: group.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get group_events_path(group_id: group.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "GET #new(イベント作成ページ)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get new_group_event_path(group_id: group.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get new_group_event_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get new_group_event_path(group_id: group.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get new_group_event_path(group_id: group.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get new_group_event_path(group_id: group.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "POST #create(イベント作成)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        context '有効な属性値の場合' do
          it 'イベントが作成されること' do
            event_params = attributes_for(:event, group_id: group.id, user_id: executive.id)
            sign_in executive
            expect do
              post group_events_path(group_id: group.id), params: { event: event_params }
            end.to change(group.events, :count).by(1)
          end

          it '#show(幹事用イベント詳細/回答)にリダイレクトされること' do
            event_params = attributes_for(:event, group_id: group.id, user_id: executive.id)
            sign_in executive
            post group_events_path(group_id: group.id), params: { event: event_params }
            expect(response).to redirect_to "/groups/#{group.id}/events/#{Event.last.id}"
          end
        end

        context '無効な属性値の場合' do
          it 'イベントが作成されないこと' do
            event_params = attributes_for(:event, :invalid)
            sign_in executive
            expect do
              post group_events_path(group_id: group.id), params: { event: event_params }
            end.to change(group.events, :count).by(0)
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          event_params = attributes_for(:event, group_id: group.id)
          sign_in member
          post group_events_path(group_id: group.id), params: { event: event_params }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          event_params = attributes_for(:event, group_id: group.id)
          sign_in other_member
          post group_events_path(group_id: group.id), params: { event: event_params }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        event_params = attributes_for(:event, group_id: group.id)
        post group_events_path(group_id: group.id), params: { event: event_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        event_params = attributes_for(:event, group_id: group.id)
        post group_events_path(group_id: group.id), params: { event: event_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:event) { create(:event, group_id: group.id, name: 'before_event') }

  describe "GET #show(幹事用イベント詳細/回答)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get group_event_path(group_id: group.id, id: event.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get group_event_path(group_id: group.id, id: event.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "GET #show(幹事用イベント詳細/回答)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get details_group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '200レスポンスを返すこと' do
          sign_in member
          get details_group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '200'
        end
      end

      context '外部のメンバーとして' do
        it '200レスポンスを返すこと' do
          sign_in other_member
          get details_group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '200'
        end
      end
    end

    context 'ゲストとして' do
      it '200レスポンスを返すこと' do
        get details_group_event_path(group_id: group.id, id: event.id)
        expect(response).to have_http_status '200'
      end
    end
  end

  describe "GET #edit(イベント編集ページ)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get edit_group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get edit_group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get edit_group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get edit_group_event_path(group_id: group.id, id: event.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get edit_group_event_path(group_id: group.id, id: event.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "PATCH #update(イベント編集)" do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        context '有効な属性値の場合' do
          it 'イベントが編集されること' do
            event_params = attributes_for(:event, name: 'after_event')
            sign_in executive
            patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
            expect(event.reload.name).to eq 'after_event'
          end

          it '#show(幹事用イベント詳細/回答)にリダイレクトされること' do
            event_params = attributes_for(:event, name: 'after_event')
            sign_in executive
            patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
            expect(response).to redirect_to "/groups/#{group.id}/events/#{event.id}"
          end
        end

        context '無効な属性値の場合' do
          it 'イベントが編集されないこと' do
            event_params = attributes_for(:event, :invalid)
            sign_in executive
            patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
            expect(event.reload.name).to eq 'before_event'
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          event_params = attributes_for(:event, name: 'after_event')
          sign_in member
          patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          event_params = attributes_for(:event, name: 'after_event')
          sign_in other_member
          patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        event_params = attributes_for(:event, name: 'after_event')
        patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        event_params = attributes_for(:event, name: 'after_event')
        patch group_event_path(group_id: group.id, id: event.id), params: { event: event_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe "DELETE #destroy(イベント削除)" do
    context '認証済みのユーザーとして' do
      # context 'そのサークルの幹事なら' do
      #   it 'イベントが削除されること' do
      #     sign_in executive
      #     expect do
      #       delete group_event_path(group_id: group.id, id: event.id)
      #     end.to change(group.events, :count).by(-1)
      #   end
      # end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          delete group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          delete group_event_path(group_id: group.id, id: event.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        delete group_event_path(group_id: group.id, id: event.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        delete group_event_path(group_id: group.id, id: event.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
