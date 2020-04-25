class FeesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_and_event
  before_action :cannot_access_to_other_groups
  before_action :only_executives_can_access

  def new
    @executives = User.executives(@group)
    @batch_fee = @event.fees.build
  end

  def create
    fee = @event.fees.build(fee_params)
    if fee.save
      create_or_update_transaction(group: @group, event: @event, fee: fee)
    else
      @executives = User.executives(@group)
      @batch_fee = @event.fees.build
      flash_and_render(key: :danger, message: '間違いがあります。', action: 'new')
    end
  end

  def update
    fee = @event.fees.find(params[:id])
    if fee.update(fee_params)
      create_or_update_transaction(group: @group, event: @event, fee: fee)
    else
      @executives = User.executives(@group)
      @batch_fee = @event.fees.build
      flash_and_render(key: :danger, message: '間違いがあります。', action: 'new')
    end
  end

  def batch
    @batch_fee = @event.fees.build(fee_params)
    @batch_fee.valid?
    @batch_fee.errors.messages.delete(:grade)
    if @batch_fee.errors.messages.blank?
      fee = create_or_update_fee(event: @event, batch_fee: @batch_fee)
      batch_create_or_update_transaction(group: @group, event: @event, fee: fee)
    else
      @executives = User.executives(@group)
      @batch_fee = @event.fees.build
      flash_and_render(key: :danger, message: '間違いがあります。', action: 'new')
    end
  end

  private

    def fee_params
      params.require(:fee).permit(:deadline, :amount, :creditor_id, :grade)
    end

    def set_group_and_event
      @event = Event.find(params[:event_id])
      @group = @event.group
    end

    def create_or_update_transaction(group:, event:, fee:)
      grade = fee.grade
      members = User.members_by_grade(group: group, grade: grade)
      NewTransactionsJob.perform_later(members: members, event: event, fee: fee, current_user: current_user) if members.any?
      number = User.grades[grade.to_sym]
      flash_and_redirect(key: :success, message: "#{number}年生の支払い情報を保存しました。", redirect_url: new_event_fee_url(event_id: event.id))
    end

    def batch_create_or_update_transaction(group:, event:, fee:)
      members = User.members(group)
      NewTransactionsJob.perform_later(members: members, event: event, fee: fee, current_user: current_user) if members.any?
      flash_and_redirect(key: :success, message: '全学年の支払い情報を一括保存しました。', redirect_url: new_event_fee_url(event_id: event.id))
    end

    def create_or_update_fee(event:, batch_fee:)
      Fee.grades.count.times do |i|
        fee = event.fees.find_by(grade: i)
        if fee.blank?
          event.create(
            amount: batch_fee.amount,
            deadline: batch_fee.deadline,
            creditor_id: batch_fee.creditor_id,
            grade: i
          )
        else
          fee.update(
            amount: batch_fee.amount,
            deadline: batch_fee.deadline,
            creditor_id: batch_fee.creditor_id
          )
        end
      end
      event.fees.first
    end

    # def flash_message(number)
    #   number.zero? ? '出席するその他の人たちに通知しました。' : "出席する#{number}年生に通知しました。"
    # end
end
