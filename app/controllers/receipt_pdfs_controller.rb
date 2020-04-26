# frozen_string_literal: true

class ReceiptPdfsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :show_only_completed_transaction

  def show
    @event = Event.find(@transaction.event_id)
    debtor = User.find(@transaction.debtor_id)
    respond_to do |format|
      format.html
      format.pdf do
        receipt_pdf = ReceiptPdf.new(debtor: debtor, event: @event, transaction: @transaction)
        send_data receipt_pdf.render,
                  filename: 'receipt.pdf',
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  private

    def show_only_completed_transaction
      @transaction = Transaction.find_by(url_token: params[:url_token])
      flash_and_redirect(key: :danger, message: 'エラーが発生しました', redirect_url: home_url) unless @transaction.completed?
    end
end
