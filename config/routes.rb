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
    get 'users/edit_profile', to: 'users/registrations#edit_profile'
    get 'users/edit_password', to: 'users/registrations#edit_password'
    put 'users/update_profile', to: 'users/registrations#update_profile'
    put 'users/update_password', to: 'users/registrations#update_password'
    get 'users/completed', to: 'users/registrations#completed'
  end

  root 'homes#landing'
  get 'home', to: 'homes#index', as: 'home'
  get 'faq', to: 'homes#faq', as: 'faq'
  get 'terms_of_service', to: 'homes#terms_of_service', as: 'terms_of_service'
  get 'privacy_policy', to: 'homes#privacy_policy', as: 'privacy_policy'
  get 'contact', to: 'homes#contact', as: 'contact'
  get 'users/csv_template', to: 'users#csv_template', as: 'csv_template'
  # get 'groups/:group_id/users/share', to: 'users#share', as: 'share'
  resources :groups, only: %i[new create edit update] do

    member do
      # get :deposit
      # get :statistics
      get :change
      get :inheritable_search
      post :inherit
      get :assignable_search
      post :assign
      get :resign
    end
    resources :users, only: %i[index new] do
      collection do
        post :batch
        get  :share
      end
    end
    resources :events do
      member do
        get :details
      end
    end
    resources :group_users, only: :destroy do
      collection do
        post :invite
      end
    end
    # resources :orders, only: %i[index]
  end

  resource :users, only: [] do
    resources :transactions, only: %i[edit update], controller: 'users/transactions', param: :url_token
  end
  resources :users, only: [] do
    collection do
      get :join
      get :leave
      get :withdraw
    end
    resources :transactions, only: %i[index]
    resources :transactions, only: %i[create], controller: 'users/transactions', param: :url_token do
      collection do
        get :lend
        get :borrow
      end
    end
    resources :events, only: [] do
      collection do
        get :list
      end
    end
  end

  resources :events, only: [] do
    resources :transactions, only: %i[edit update], controller: 'events/transactions', param: :url_token
    resources :fees, only: %i[new create update] do
      collection do
        post :batch
      end
    end
    resources :answers, only: %i[create edit update]
  end

  resources :transactions, only: [], param: :url_token do
    member do
      get :receipt, to: 'receipt_pdfs#show'
      patch :change
    end
  end

  resources :group_users, only: :destroy do
    collection do
      post :join
      delete :leave
    end
  end

  resources :answers, only: [] do
    member do
      patch :change
    end
  end

  # resources :questionnaires, only: %i[index create show] do
  #   resources :responses, only: %i[create update]
  # end

  # resources :orders, only: [] do
  #   collection do
  #     get 'step1'
  #     get 'step2'
  #   end
  # end
  # post 'orders/submit', to: 'orders#submit'
  # post 'orders/paypal/create_payment', to: 'orders#paypal_create_payment', as: :paypal_create_payment
  # post 'orders/paypal/execute_payment', to: 'orders#paypal_execute_payment', as: :paypal_execute_payment
  # post 'orders/paypal/create_subscription', to: 'orders#paypal_create_subscription', as: :paypal_create_subscription
  # post 'orders/paypal/execute_subscription', to: 'orders#paypal_execute_subscription', as: :paypal_execute_subscription


  ##################### ADMIN ################################
  namespace :admin do
    get 'homes/index'
    resources :questionnaires, only: %i[index new create edit update destroy] do
      resources :chooses, only: %i[index create destroy]
    end
    resources :choices, only: %i[index new create edit update destroy]
  end

  # Basic認証時のユーザー名とパスワードを設定する
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == [ENV['SIDEKIQ_USER'], ENV['SIDEKIQ_PASSWORD']] # 環境変数にて設定
  end

  mount Sidekiq::Web => 'admin/sidekiq'

  # エラーページ
  get '*anything' => 'errors#routing_error'
end
