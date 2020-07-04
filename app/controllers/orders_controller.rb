# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :executives_cannot_access, except: [:index]
  before_action :set_group, only: [:index]
  before_action :only_executives_can_access, only: [:index]
  before_action :save_to_session, only: [:step2]
  before_action :prepare_new_order, only: %i[paypal_create_payment paypal_create_subscription]

  def index
    @order = Order.find_by(user_id: current_user.id, status: Order.statuses[:paid])
    @product = Product.find(@order.product_id)
  end

  def step1
    @group = Group.new
  end

  def step2
    @subscriptions = Product.limit(3)
  end

  def submit
    @order = Orders::Paypal.finish(charge_id: order_params[:charge_id], current_user: current_user)
    if @order&.save # @orderがnilだとしてもエラーにならない(ぼっち演算子)
      group = Group.new(
        name: session[:name],
        email: session[:email],
        group_number: session[:group_number],
        payment_status: Group.payment_statuses[:paid]
      )
      if @order.paid? && group.save
        # Success is rendered when order is paid and saved
        GroupUser.create!(
          group_id: group.id,
          user_id: current_user.id,
          role: GroupUser.roles[:executive]
        )
        SubscriptionMailer.new_subscription(group: group, user: current_user, order: @order).deliver_later
        flash_and_redirect(key: :success, message: "おめでとうございます！購読が開始され、あなたは#{group.name}の幹事となりました！", redirect_url: home_url) and return
      elsif @order.failed? && !@order.error_message.blank?
        # Render error only if order failed and there is an error_message
        render html: @order.error_message
      end
    else
      ErrorSlackNotification.new_subscription_error_notify(title: 'サブスクリプション提出時(submit)のエラー',
                                                           message: "#{current_user&.name}さん(ID: #{current_user&.id})のエラー")
      render json: { error: '失敗1' }, status: :unprocessable_entity
    end
  end

  def paypal_create_payment
    result = Orders::Paypal.create_payment(order: @order, product: @product)
    if result
      render json: { token: result }, status: :ok
    else
      puts '失敗２'
      render json: { error: '失敗2' }, status: :unprocessable_entity
    end
  end

  def paypal_execute_payment
    if Orders::Paypal.execute_payment(payment_id: params[:paymentID], payer_id: params[:payerID])
      render json: {}, status: :ok
    else
      puts '失敗３'
      render json: { error: '失敗3' }, status: :unprocessable_entity
    end
  end

  def paypal_create_subscription
    result = Orders::Paypal.create_subscription(order: @order, product: @product)
    if result
      render json: { token: result }, status: :ok
    else
      ErrorSlackNotification.new_subscription_error_notify(title: 'サブスクリプション作成時(paypal_create_subscription)のエラー',
                                                           message: "#{current_user&.name}さん(ID: #{current_user&.id})のエラー")
      nil
      # render json: {error: '失敗4'}, status: :unprocessable_entity
    end
  end

  def paypal_execute_subscription
    result = Orders::Paypal.execute_subscription(token: params[:subscriptionToken])
    if result
      render json: { id: result }, status: :ok
    else
      ErrorSlackNotification.new_subscription_error_notify(title: 'サブスクリプション実行時(paypal_execute_subscription)のエラー',
                                                           message: "#{current_user&.name}さん(ID: #{current_user&.id})のエラー")
      nil
      # render json: {error: '失敗5'}, status: :unprocessable_entity
    end
  end

  private

    # orderの初期化とuser, product, priceのセット
    def prepare_new_order
      @order = Order.new(order_params)
      @order.user_id = current_user.id
      @product = Product.find(@order.product_id)
      @order.price_cents = @product.price_cents
    end

    def order_params
      params.require(:orders).permit(:product_id, :token, :charge_id)
    end

    def executives_cannot_access
      flash_and_redirect(key: :danger, message: 'すでにグループの幹事である人は新しくグループを作成することができません', redirect_url: home_url) if current_user_group
    end

    def group_params
      params.require(:group).permit(:name, :email, :group_number)
    end

    def save_to_session
      return flash_and_redirect(key: :danger, message: 'グループの情報を入力してください', redirect_url: step1_orders_url) unless params[:group]

      session[:name] = group_params[:name]
      session[:email] = group_params[:email]
      session[:group_number] = group_params[:group_number]

      @group = Group.new(
        name: session[:name],
        email: session[:email],
        group_number: session[:group_number]
      )
      render 'step1' unless @group.valid?
    end
end
