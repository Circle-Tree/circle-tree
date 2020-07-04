# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  let(:user) { create(:user) }

  describe 'GET #index' do
    context '認証済みのユーザーとして' do
      it '正常なレスポンスを返すこと' do
        sign_in user
        get home_path
        expect(response).to have_http_status '200'
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get home_path
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get home_path
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'GET #landing' do
    it '正常なレスポンスを返すこと' do
      get root_path
      expect(response).to have_http_status '200'
    end
  end

  describe 'GET #faq' do
    context '認証済みのユーザーとして' do
      it '正常なレスポンスを返すこと' do
        sign_in user
        get faq_path
        expect(response).to have_http_status '200'
      end
    end

    context 'ゲストとして' do
      it '302レスポンスを返すこと' do
        get faq_path
        expect(response).to have_http_status '302'
      end

      it 'サインイン画面にリダイレクトすること' do
        get faq_path
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe 'GET #terms_of_service' do
    it '正常なレスポンスを返すこと' do
      get terms_of_service_path
      expect(response).to have_http_status '200'
    end
  end

  describe 'GET #privacy_policy' do
    it '正常なレスポンスを返すこと' do
      get privacy_policy_path
      expect(response).to have_http_status '200'
    end
  end

  describe 'GET #contact' do
    it '正常なレスポンスを返すこと' do
      get contact_path
      expect(response).to have_http_status '200'
    end
  end
end
