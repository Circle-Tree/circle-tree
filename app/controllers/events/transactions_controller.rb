# frozen_string_literal: true

class Events::TransactionsController < TransactionsController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_and_event
  before_action :cannot_access_to_other_groups
  before_action :only_executives_can_access

  def edit
    @transaction = Event::Transaction.find_by(url_token: params[:url_token])
    @user = @transaction.debtor
    @executives = User.executives(@group)
  end

  def update
    @transaction = Event::Transaction.find_by(url_token: params[:url_token])
    if @transaction.update(update_transaction_params)
      NotificationMailer.update_event_transaction(group: @group, transaction: @transaction, current_user: current_user).deliver_later
      flash[:success] = "#{@transaction.debtor.name}さんの支払い情報を更新しました"
      redirect_to group_event_url(group_id: @event.group_id, id: @event.id)
    else
      @user = @transaction.debtor
      @executives = User.executives(@group)
      render 'edit'
    end
  end

  private

    def update_transaction_params
      params.require(:event_transaction).permit(:deadline, :debt, :payment, :creditor_id)
    end

    def set_group_and_event
      @event = Event.find(params[:event_id])
      @group = @event.group
    end

    # 幹事のみアクセス可能
    def only_executives_can_access
      return if current_user_group == @group

      # flash[:danger] = '幹事しかアクセスできません'
      raise Forbidden
    end
end
