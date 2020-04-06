# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
Rails.application.routes.draw do
  # get 'receipt_pdfs/index', to: 'receipt_pdfs#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_out', to: 'users/sessions#destroy'
  end

  root 'homes#index'
  get 'homes/index'
  get 'users/csv_template', to: 'users#csv_template', as: 'csv_template'
  # get 'groups/:group_id/users/share', to: 'users#share', as: 'share'
  resources :groups, except: [:new, :create] do

    member do
      get :dashboard
      get :deposit
      get :statistics
      get :change
      get :inheritable_search
      post :inherit
      get :assignable_search
      post :assign
      get :resign
      post :invite
    end
    resources :users, only: [:index,:new] do
      collection do
        post :batch
        get  :share
      end
    end
    resources :events
    resources :orders, only: %i[index]
  end

  resources :users, only: [] do
    member do
      get :edit_profile
      get :edit_password
    end
    resources :transactions, only: [:index]
    resources :events, only: [] do
      collection do
        get 'list'
      end
    end
  end

  resources :events, only: [] do
    resources :transactions, only: %i[new create edit update], controller: 'events/transactions', param: :url_token
    resources :answers, only: %i[edit update]
  end

  resources :transactions, only: %i[edit update], param: :url_token do
    member do
      get :receipt, to: 'receipt_pdfs#show'
      patch :change
    end
  end

  resources :answers, only: [] do
    member do
      patch :change
    end
  end

  resources :orders, only: [] do
    collection do
      get 'step1'
      get 'step2'
    end
  end
  post 'orders/submit', to: 'orders#submit'
  post 'orders/paypal/create_payment', to: 'orders#paypal_create_payment', as: :paypal_create_payment
  post 'orders/paypal/execute_payment', to: 'orders#paypal_execute_payment', as: :paypal_execute_payment
  post 'orders/paypal/create_subscription', to: 'orders#paypal_create_subscription', as: :paypal_create_subscription
  post 'orders/paypal/execute_subscription', to: 'orders#paypal_execute_subscription', as: :paypal_execute_subscription


  ##################### ADMIN ################################
  namespace :admin do
    get 'homes/index'
  end

  # Basic認証時のユーザー名とパスワードを設定する
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [ENV['SIDEKIQ_USER'], ENV['SIDEKIQ_PASSWORD']] #環境変数にて設定
  end

  mount Sidekiq::Web => 'admin/sidekiq'

  # エラーページ
  get '*anything' => 'errors#routing_error'
end
