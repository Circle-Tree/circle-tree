# frozen_string_literal: true

class Users::TransactionsController < TransactionsController
  before_action :authenticate_user!

  def lend
    @user = User.find(params[:user_id])
    @transaction = Individual::Transaction.new
  end

  def borrow
    @user = User.find(params[:user_id])
    @transaction = Individual::Transaction.new
  end

  def create
    @user = User.find(params[:user_id])
    @transaction = Individual::Transaction.new(user_transaction_params)
    @transaction.url_token = SecureRandom.hex(10)
    if @transaction.save
      if @transaction.lending?(user: current_user)
        TransactionNotificationMailer.new_lending_transaction(user: @user, current_user: current_user).deliver_later
      else
        TransactionNotificationMailer.new_borrowing_transaction(user: @user, current_user: current_user).deliver_later
      end
      flash_and_redirect(key: :success, message: '作成しました。', redirect_url: user_transactions_path(user_id: current_user.id))
    else
      if @transaction.lending?(user: current_user)
        render 'lend'
      else
        render 'borrow'
      end
    end
  end

  def edit
    @transaction = Individual::Transaction.find_by(url_token: params[:url_token])
    if @transaction.lending?(user: current_user)
      @user = @transaction.debtor
    else
      @user = @transaction.creditor
    end
  end

  def update
    @transaction = Individual::Transaction.find_by(url_token: params[:url_token])
    if @transaction.update(update_user_transaction_params)
      if @transaction.lending?(user: current_user)
        TransactionNotificationMailer.update_lending_transaction(user: @transaction.debtor, current_user: current_user).deliver_later
      else
        TransactionNotificationMailer.update_borrowing_transaction(user: @transaction.creditor, current_user: current_user).deliver_later
      end
      flash_and_redirect(key: :success, message: '変更しました。', redirect_url: user_transactions_path(user_id: current_user.id))
    else
      if @transaction.lending?(user: current_user)
        @user = @transaction.debtor
      else
        @user = @transaction.creditor
      end
      render 'edit'
    end
  end

  private

    def user_transaction_params
      params.require(:individual_transaction).permit(:deadline, :debt, :payment, :debtor_id, :creditor_id)
    end

    def update_user_transaction_params
      params.require(:individual_transaction).permit(:deadline, :debt, :payment)
    end
end
