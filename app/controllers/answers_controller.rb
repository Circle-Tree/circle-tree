# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[update change]

  def change
    if params[:answer_id]
      answer = current_user.answers.find(params[:answer_id])
      if answer&.update(status: params[:status])
        flash.now[:success] = '回答を変更しました'
      else
        flash.now[:danger] = '回答を変更できませんでした'
      end
      render partial: 'events/answer_select', locals: { answer: answer }
    end
  end

  def update
    if @answer.update(answer_params)
      flash_and_redirect(key: :success, message: '回答を変更しました', redirect_url: details_group_event_url(group_id: @event.group_id, id: @event.id))
    else
      flash_and_render(key: :danger, message: '回答を変更できませんでした', action: 'events/details')
    end
  end

  private

    def answer_params
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
