class FeesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :set_group_and_event
  before_action :cannot_access_to_other_groups
  before_action :only_executives_can_access

  def new
    @executives = User.executives(@group)
  end

  def create
    fee = @event.fees.build(fee_params)
    if fee.save
      grade = fee.grade
      members = User.members_by_grade(group: @group, grade: grade)
      number = User.grades[grade.to_sym]
      if members.any?
        NewTransactionsJob.perform_later(members: members, event: @event, fee: fee, current_user: current_user)
        if number.zero?
          message = '出席するその他の人たちに通知しました。'
        else
          message = "出席する#{number}年生に通知しました。"
        end
        flash_and_redirect(key: :success, message: message, redirect_url: new_event_fee_url(event_id: @event.id))
      else
        flash_and_redirect(key: :success, message: "#{number}年生の支払い情報を保存しました。", redirect_url: new_event_fee_url(event_id: @event.id))
      end
    else
      @executives = User.executives(@group)
      flash_and_render(key: :danger, message: '間違いがあります。', action: 'new')
    end
  end

  def update
    fee = @event.fees.find(params[:id])
    if fee.update(fee_params)
      grade = fee.grade
      members = User.members_by_grade(group: @group, grade: grade)
      number = User.grades[grade.to_sym]
      if members.any?
        NewTransactionsJob.perform_later(members: members, event: @event, fee: fee, current_user: current_user)
        if number.zero?
          message = '出席するその他の人たちに通知しました。'
        else
          message = "出席する#{number}年生に通知しました。"
        end
        flash_and_redirect(key: :success, message: message, redirect_url: new_event_fee_url(event_id: @event.id))
      else
        flash_and_redirect(key: :success, message: "#{number}年生の支払い情報を保存しました。", redirect_url: new_event_fee_url(event_id: @event.id))
      end
    else
      @executives = User.executives(@group)
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

    # def change_fee(event:, grade:, transaction:)
    #   fee = event.fees.find_by(grade: grade)
    #   if fee.blank?
    #     event.fees.create(
    #       amount: transaction.debt,
    #       grade: grade,
    #       deadline: transaction.deadline,
    #       creditor_id: transaction.creditor_id
    #     )
    #   else
    #     fee.update(
    #       amount: transaction.debt,
    #       deadline: transaction.deadline,
    #       creditor_id: transaction.creditor_id
    #     )
    #   end
    # end
end
