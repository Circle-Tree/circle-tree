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
      transaction = nil
      grade = params[:grade]
      members = User.members_by_grade(group: @group, grade: grade)
      puts members.count
      if members.any?
        NewTransactionsJob.perform_later(members: members, event: @event, params: create_transaction_params,
                                        current_user: current_user)
        number = User.grades[grade.to_sym]
        if number.zero?
          message = '出席するその他の人たちに通知しました。'
        else
          message = "出席する#{number}年生に通知しました。"
        end
        flash_and_redirect(key: :success, message: message, redirect_url: new_event_transaction_url(event_id: @event.id))
      else
        @executives = User.executives(@group)
        flash_and_render(key: :danger, message: 'メンバーがいないため作成できませんでした。', action: 'new')
      end
    else
      puts '4'
      @transaction = transaction
      @executives = User.executives(@group)
      @transaction = nil
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
