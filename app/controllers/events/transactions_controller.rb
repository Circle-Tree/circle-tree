# frozen_string_literal: true

class Events::TransactionsController < TransactionsController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_and_event
  before_action :cannot_access_to_other_groups
  before_action :only_executives_can_access

  # def new
  #   @transaction = Event::Transaction.new
  #   @users = []
  #   GroupUser.where(group_id: @group.id).each do |relationship|
  #     user = User.find(relationship.user_id)
  #     unless Event::Transaction.where(group_id: @group.id, event_id: @event.id, debtor_id: relationship.user_id)
  #       @users << user
  #     end
  #   end
  # end

  # def create
  #   @transaction = Event::Transaction.new(transaction_params)
  #   @users = [] # createでも定義しないといけない
  #   GroupUser.where(group_id: @group.id).each do |relationship|
  #     user = User.find(relationship.user_id)
  #     unless Event::Transaction.where(group_id: @group.id, event_id: @event.id, debtor_id: relationship.user_id)
  #       @users << user
  #     end
  #   end
  #   if @transaction.save
  #     flash[:success] = '作成成功！'
  #     redirect_to group_event_url(group_id: @group.id, id: @event.id)
  #   else
  #     render 'new'
  #   end
  # end

  def edit
    @transaction = Event::Transaction.find_by(url_token: params[:url_token])
    @user = User.find(@transaction.debtor_id)
    @executives = User.executives(@group)
  end

  def update
    @transaction = Event::Transaction.find_by(event_id: @event.id, url_token: params[:url_token])
    if params[:event_transaction][:payment] == params[:event_transaction][:debt]
      @transaction.completed = true
    else
      @transaction.completed = false
    end
    if @transaction.update_attributes(update_transaction_params)
      user = User.find(@transaction.debtor_id)
      flash[:success] = "#{user.name}さんの支払い情報を更新しました"
      redirect_to group_event_url(group_id: @event.group_id, id: @event.id)
    else
      @user = User.find(@transaction.debtor_id)
      @executives = User.executives(@group)
      render 'edit'
    end
  end

  private

    def update_transaction_params
      params.require(:event_transaction).permit(:deadline, :debt, :payment, :completed, :creditor_id)
    end

    def set_group_and_event
      @event = Event.find(params[:event_id])
      @group = @event.group
    end

    # 幹事のみアクセス可能
    def only_executives_can_access
      return unless GroupUser.general_relationship(group: @group, user: current_user)

      flash[:danger] = '幹事しかアクセスできません'
      raise Forbidden
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      return if @group.my_group?(current_user)

      flash[:danger] = '所属していないグループにはアクセスできません'
      raise Forbidden
    end
end
