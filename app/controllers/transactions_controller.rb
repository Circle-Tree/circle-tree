# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[index]
  def index
    @transactions = Transaction.joins(event: :answers).includes(:group, :event).where(debtor_id: current_user.id, event: { answers: { status: 'attending' } }).distinct.order(deadline: :asc).page(params[:page]).per(5)
    # @paid_total_amount = Event::Transaction.paid_total_amount(current_user)
    # @unpaid_total_amount = Event::Transaction.unpaid_total_amount(current_user)
    user = current_user
    @total_payment = Transaction.total_payment_by_user(user)
    all_debts = Transaction.joins(event: :answers).where(completed: false, debtor_id: user.id, event: { answers: { status: 'attending' } }).distinct
    t = Time.current.end_of_day
    unpaid_debts = all_debts.where('deadline <= ?', t)
    @total_unpaid_debt = unpaid_debts.sum('debt') - unpaid_debts.sum('payment')
    expected_debts = all_debts.where('deadline >= ?', t)
    @total_expected_debt = expected_debts.sum('debt') - expected_debts.sum('payment')
    @urgent_expected_debts = all_debts.where(deadline: t..t.since(7.days)).order(deadline: :asc).limit(2)
  end

  # def new
  #   @group = Group.find(params[:group_id])
  #   @event = Event.find(params[:event_id])
  #   @transaction = Transaction.new
  # end

  # def create
  #   @group = Group.find(params[:group_id])
  #   @event = Event.find(params[:event_id])
  #   @transaction = Transaction.new(transaction_params)
  #   if @transaction.save
  #     flash[:success] = 'トランザクション作成成功！'
  #     redirect_to group_event_url(group_id: @group.id, id: @event.id)
  #   else
  #     render 'new'
  #   end
  # end

  def edit
  end

  def update
  end

  def change
    if params[:url_token] && transaction = Transaction.find_by(url_token: params[:url_token])
      debt = transaction.debt
      if transaction&.update(payment: debt, completed: true)
        flash.now[:success] = '変更しました'
      else
        flash.now[:danger] = '変更できませんでした'
      end
      render partial: 'events/show/transaction', locals: { transaction: transaction }
    end
  end


  # private

  # def transaction_params
  #   params.require(:transaction).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
  # end

  # def transaction_params
  #  params.require(params[:type].underscore.gsub('/', '_').to_sym).permit(:debtor_id, :creditor_id, :event_id, :group_id, :deadline, :debt, :payment)
  # end
  # "Transaction::Event".underscore => "transaction/event"
  # "transaction/event".gsub('/', '_') => "transaction_event" 第1引数にマッチしたものを第2引数に置き換える
  # .to_sym => 文字列をシンボルに変換する

end
