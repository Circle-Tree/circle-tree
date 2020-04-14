# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[index]
  def index
    @today = Time.current.midnight
    transactions = Transaction.transactions_for_attending_event_by_user(current_user)
    @transactions = transactions.includes(:creditor).order(deadline: :asc).page(params[:page]).per(5)
    @total_payment = transactions.sum { |transaction| transaction[:payment] }
    uncompleted_transactions = Transaction.uncompleted_transactions_by_user(transactions)
    overdue_transactions = Transaction.overdue_transactions_by_user(uncompleted_transactions: uncompleted_transactions, today: @today)
    @total_overdue_debt = overdue_transactions.sum { |transaction| transaction[:debt] } - overdue_transactions.sum { |transaction| transaction[:payment] }
    non_overdue_transactions = uncompleted_transactions - overdue_transactions
    @total_non_overdue_debt = non_overdue_transactions.sum { |transaction| transaction[:debt] } - non_overdue_transactions.sum { |transaction| transaction[:payment] }
    @urgent_transactions = Transaction.urgent_transactions_by_user(non_overdue_transactions: non_overdue_transactions, max: 2, today: @today)
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
      if transaction&.update(payment: debt)
        render partial: 'events/show/transaction', locals: { transaction: transaction }
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
