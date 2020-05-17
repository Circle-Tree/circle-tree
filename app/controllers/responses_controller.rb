# frozen_string_literal: true

class ResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration

  def create
    @response = Response.new(responses_params)
    if @response.save
      flash_and_redirect(key: :success, message: '回答が送信されました！', redirect_url: questionnaire_url(id: @response.questionnaire.id))
    else
      render 'questionnaires/show'
    end
  end

  def update
    @response = Response.find(params[:id])
    if @response.update(responses_params)
      flash_and_redirect(key: :success, message: '回答が変更されました！', redirect_url: questionnaire_url(id: @response.questionnaire.id))
    else
      render 'questionnaires/show'
    end
  end

  private

    def responses_params
      params.require(:response).permit(:questionnaire_id, :user_id, :choice_id)
    end
end
