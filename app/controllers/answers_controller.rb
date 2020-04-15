# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :other_user_cannot_access, only: %i[update change]

  def create
    @answer = Answer.new(create_answer_params)
    @event = Event.find(params[:event_id])
    if @answer.status == 'unanswered'
      @answer = nil
      @group = @event.group
      @attending_answers = @event.answers.where(status: 'attending')
      flash_and_render(key: :danger, message: '回答を選択してください。', action: 'events/details')
    elsif @answer.save
      # Transaction作成？
      flash_and_redirect(key: :success, message: '回答を送信しました。', redirect_url: details_group_event_url(group_id: @event.group_id, id: @event.id))
    else
      @answer = nil
      @group = @event.group
      @attending_answers = @event.answers.where(status: 'attending')
      ErrorSlackNotification.general_error_notify(title: '回答の作成に失敗', message: "#{current_user&.name}(ID: #{current_user&.id})さんがイベント(#{@event&.id})の回答作成に失敗")
      flash_and_render(key: :danger, message: '回答を送信できませんでした。', action: 'events/details')
    end
  end

  def change
    if params[:answer_id]
      answer = current_user.answers.find(params[:answer_id])
      if answer&.update(status: params[:status])
        flash.now[:success] = '回答を変更しました'
      else
        ErrorSlackNotification.general_error_notify(title: '回答の変更に失敗', message: "#{current_user&.name}(ID: #{current_user&.id})さんがイベント(#{answer&.event&.id})の回答(#{answer&.id})に失敗")
        render json: { error: '404 error' }, status: 404
      end
      event = answer.event
      render partial: 'events/list/answer_select', locals: { answer: answer, event: event }
    else
      ErrorSlackNotification.general_error_notify(title: '回答の変更に失敗', message: "#{current_user&.name}(ID: #{current_user&.id})さんがイベント回答変更に失敗")
      render json: { error: '404 error' }, status: 404
    end
  end

  def update
    if @answer.update(update_answer_params)
      flash_and_redirect(key: :success, message: '回答を変更しました', redirect_url: details_group_event_url(group_id: @event.group_id, id: @event.id))
    else
      @group = @event.group
      @attending_answers = @event.answers.where(status: 'attending')
      ErrorSlackNotification.general_error_notify(title: '回答の保存に失敗', message: "#{current_user&.name}(ID: #{current_user&.id})さんがイベント(#{@event&.id})の回答(#{@answer&.id})に失敗")
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
