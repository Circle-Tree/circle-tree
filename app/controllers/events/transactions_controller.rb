# frozen_string_literal: true

class Events::TransactionsController < TransactionsController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_and_event
  before_action :cannot_access_to_other_groups
  before_action :only_executives_can_access

  def new
    @transaction = Event::Transaction.new
    @executives = User.executives(@group)
  end

  def create
    transaction = @event.transactions.build(create_transaction_params)
    transaction.debtor_id = 1
    if transaction.valid?
      transaction.debtor_id = nil
      grade = params[:grade]
      change_fee(event: @event, grade: grade, transaction: transaction)
      members = User.members_by_grade(group: @group, grade: grade)
      number = User.grades[grade.to_sym]
      if members.any?
        NewTransactionsJob.perform_later(members: members, event: @event, params: create_transaction_params, current_user: current_user)
        if number.zero?
          message = '出席するその他の人たちに通知しました。'
        else
          message = "出席する#{number}年生に通知しました。"
        end
        flash_and_redirect(key: :success, message: message, redirect_url: new_event_transaction_url(event_id: @event.id))
      else
        flash_and_redirect(key: :success, message: "#{number}年生の支払い情報を保存しました。", redirect_url: new_event_transaction_url(event_id: @event.id))
      end
    else
      @transaction = transaction
      @executives = User.executives(@group)
      render 'new'
    end
  end

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

    def create_transaction_params
      params.require(:event_transaction).permit(:deadline, :debt, :creditor_id, :grade)
    end

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

    def change_fee(event:, grade:, transaction:)
      fee = event.fees.find_by(grade: grade)
      if fee.blank?
        event.fees.create(amount: transaction.debt, grade: grade)
      else
        fee.update(amount: transaction.debt)
      end
    end
end
