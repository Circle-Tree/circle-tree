# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[update change]

  def create
    @answer = Answer.new(create_answer_params)
    @event = Event.find(params[:event_id])
    if @answer.status != 'unanswered' && @answer.save
      # Event::Transaction.create(
      #   deadline: @event.pay_deadline,
      #   payment: 0,
      #   debtor_id: current_user.id,
      #   creditor_id: @event.user_id,
      #   completed: false,
      #   url_token: SecureRandom.hex(10),
      #   event_id: @event.id,
      #   group_id: @event.group_id
      # )
      flash_and_redirect(key: :success, message: '回答を送信しました', redirect_url: details_group_event_url(group_id: @event.group_id, id: @event.id))
    else
      @answer = nil
      @group = @event.group
      @attending_answers = Answer.where(event_id: @event.id, status: 'attending')
      flash_and_render(key: :danger, message: '回答を送信できませんでした', action: 'events/details')
    end
  end

  def change
    if params[:answer_id]
      answer = current_user.answers.find(params[:answer_id])
      if answer&.update(status: params[:status])
        flash.now[:success] = '回答を変更しました'
      else
        flash.now[:danger] = '回答を変更できませんでした'
      end
      event = Event.find(answer.event_id)
      render partial: 'events/list/answer_select', locals: { answer: answer, event: event }
    end
  end

  def update
    if @answer.update(update_answer_params)
      flash_and_redirect(key: :success, message: '回答を変更しました', redirect_url: details_group_event_url(group_id: @event.group_id, id: @event.id))
    else
      @group = Group.find(@event.group_id)
      @attending_answers = Answer.where(event_id: @event.id, status: 'attending')
      flash_and_render(key: :danger, message: '回答を変更できませんでした', action: 'events/details')
    end
  end

  private

    def create_answer_params
      params.require(:answer).permit(:status, :user_id, :event_id)
    end

    def update_answer_params
      params.require(:answer).permit(:status)
    end

    def other_user_cannot_access
      @answer = current_user.answers.find(params[:id])
      @event = @answer.event
      my_answer = Answer.find_by(user_id: current_user.id, event_id: @event.id)
      return if my_answer == @answer

      flash[:danger] = 'アクセス権限がありません'
      raise Forbidden
    end
end
