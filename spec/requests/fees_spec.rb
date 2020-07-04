# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fees', type: :request do
  let(:executive) { create(:user) }
  let(:member) { create(:user) }
  let(:other_member) { create(:user) }
  let(:group) { create(:group) }
  let!(:executive_relationship) { create(:group_user, :executive, user_id: executive.id, group_id: group.id) }
  let!(:member_relationship) { create(:group_user, user_id: member.id, group_id: group.id) }
  let(:event) { create(:event, group_id: group.id) }

  describe 'GET #new(イベントの支払い情報作成ページ)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        it '正常なレスポンスを返すこと' do
          sign_in executive
          get new_event_fee_path(event_id: event.id)
          expect(response).to have_http_status '200'
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          sign_in member
          get new_event_fee_path(event_id: event.id)
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          sign_in other_member
          get new_event_fee_path(event_id: event.id)
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get new_event_fee_path(event_id: event.id)
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get new_event_fee_path(event_id: event.id)
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'POST #create(イベント支払い情報作成)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        context '有効な属性値の場合' do
          it 'イベント支払い情報が作成されること' do
            fee_params = attributes_for(:fee, creditor_id: executive.id, grade: member.grade)
            sign_in executive
            expect do
              post event_fees_path(event_id: event.id), params: { fee: fee_params }
            end.to change(event.fees, :count).by(1)
          end

          it '#new(イベントの支払い情報作成ページ)にリダイレクトすること' do
            fee_params = attributes_for(:fee, creditor_id: executive.id, grade: member.grade)
            sign_in executive
            post event_fees_path(event_id: event.id), params: { fee: fee_params }
            expect(response).to redirect_to "/events/#{event.id}/fees/new"
          end
        end

        context '無効な属性値の場合' do
          it 'イベントが作成されないこと' do
            fee_params = attributes_for(:fee, :invalid)
            sign_in executive
            expect do
              post event_fees_path(event_id: event.id), params: { fee: fee_params }
            end.to change(event.fees, :count).by(0)
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          fee_params = attributes_for(:fee, creditor_id: executive.id, grade: member.grade)
          sign_in member
          post event_fees_path(event_id: event.id), params: { fee: fee_params }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          fee_params = attributes_for(:fee, creditor_id: executive.id, grade: member.grade)
          sign_in other_member
          post event_fees_path(event_id: event.id), params: { fee: fee_params }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        fee_params = attributes_for(:fee, creditor_id: executive.id, grade: member.grade)
        post event_fees_path(event_id: event.id), params: { fee: fee_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        fee_params = attributes_for(:fee, creditor_id: executive.id, grade: member.grade)
        post event_fees_path(event_id: event.id), params: { fee: fee_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  let(:fee) { create(:fee, event_id: event.id, creditor_id: executive.id, grade: member.grade) }

  describe 'PATCH #update(イベント支払い情報編集)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        # context '有効な属性値の場合' do
        #   it 'イベントが編集されること' do
        #     fee_params = attributes_for(:fee, amount: 2000)
        #     sign_in executive
        #     patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
        #     expect(fee.reload.amount).to eq 2000
        #   end

        #   it '#new(イベントの支払い情報作成ページ)にリダイレクトすること' do
        #     fee_params = attributes_for(:fee, amount: 2000)
        #     sign_in executive
        #     patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
        #     expect(response).to redirect_to "/events/#{event.id}/fees/new"
        #   end
        # end

        context '無効な属性値の場合' do
          it 'イベントが編集されないこと' do
            fee_params = attributes_for(:fee, :invalid)
            sign_in executive
            patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
            expect(fee.reload.amount).to eq 1000
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          fee_params = attributes_for(:fee, amount: 2000)
          sign_in member
          patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          fee_params = attributes_for(:fee, amount: 2000)
          sign_in other_member
          patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        fee_params = attributes_for(:fee, amount: 2000)
        patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        fee_params = attributes_for(:fee, amount: 2000)
        patch event_fee_path(event_id: event.id, id: fee.id), params: { fee: fee_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'PATCH #batch(イベント支払い情報一括編集)' do
    context '認証済みのユーザーとして' do
      context 'そのサークルの幹事なら' do
        # context '有効な属性値の場合' do
        #   it 'イベント支払い情報が作成されること' do
        #     fee_params = attributes_for(:fee, amount: 2000)
        #     sign_in executive
        #     expect do
        #       post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
        #     end.to change(event.fees, :count).by(7)
        #   end

        #   it '#new(イベントの支払い情報作成ページ)にリダイレクトすること' do
        #     fee_params = attributes_for(:fee, amount: 2000)
        #     sign_in executive
        #     post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
        #     expect(response).to redirect_to "/events/#{event.id}/fees/new"
        #   end

        #   it 'イベント支払い情報が作成されること' do
        #     fee2 = create(:fee, event_id: event.id, creditor_id: executive.id, grade: Fee.grades[:grade1])
        #     fee3 = create(:fee, event_id: event.id, creditor_id: executive.id, grade: Fee.grades[:grade2])
        #     fee4 = create(:fee, event_id: event.id, creditor_id: executive.id, grade: Fee.grades[:grade3])
        #     fee_params = attributes_for(:fee, amount: 2000)
        #     sign_in executive
        #     expect do
        #       post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
        #     end.to change(event.fees, :count).by(4)
        #   end
        # end

        context '無効な属性値の場合' do
          it 'イベントが編集されないこと' do
            fee_params = attributes_for(:fee, :invalid)
            sign_in executive
            expect do
              post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
            end.to change(event.fees, :count).by(0)
          end
        end
      end

      context 'そのサークルの一般人なら' do
        it '403レスポンスを返すこと' do
          fee_params = attributes_for(:fee, amount: 2000)
          sign_in member
          post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
          expect(response).to have_http_status '403'
        end
      end

      context '外部のメンバーとして' do
        it '403レスポンスを返すこと' do
          fee_params = attributes_for(:fee, amount: 2000)
          sign_in other_member
          post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
          expect(response).to have_http_status '403'
        end
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        fee_params = attributes_for(:fee, amount: 2000)
        post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        fee_params = attributes_for(:fee, amount: 2000)
        post batch_event_fees_path(event_id: event.id), params: { fee: fee_params }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end
end
