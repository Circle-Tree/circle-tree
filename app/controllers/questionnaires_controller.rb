# frozen_string_literal: true

class QuestionnairesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :cannot_access_to_created_questionnaire, only: %i[show]

  def index
    @questionnaire = Questionnaire.new
    @open_questionnaires = Questionnaire.where(status: Questionnaire.statuses[:open])
    # @first_open_questionnaire = open_questionnaires.first
    # @open_questionnaires = open_questionnaires - @first_open_questionnaire
    @closed_questionnaires = Questionnaire.where(status: Questionnaire.statuses[:closed])
    # @first_closed_questionnaire = closed_questionnaires.first
    # @closed_questionnaires = closed_questionnaires - @first_closed_questionnaire
  end

  def create
    @questionnaire = Questionnaire.new(questionnaires_params)
    if @questionnaire.save
      QuestionnaireSlackNotification.created_questionnaire_notify(title: @questionnaire&.title, message: @questionnaire&.content)
      flash_and_redirect(key: :success, message: 'アンケートが送信されました！', redirect_url: questionnaires_url)
    else
      flash_and_render(key: :danger, message: '間違いがあります。', action: 'index')
    end
  end

  def show
    @choices = @questionnaire.choices
    set_form_path_and_response
  end

  private

    def questionnaires_params
      params.require(:questionnaire).permit(:title, :content, :user_id)
    end

    def cannot_access_to_created_questionnaire
      @questionnaire = Questionnaire.find(params[:id])
      flash_and_redirect(key: :danger, message: '無効なアンケートです。', redirect_url: questionnaires_url) if @questionnaire.created?
    end

    def set_form_path_and_response
      @response = Response.find_by(user_id: current_user.id, questionnaire_id: @questionnaire.id)
      if @response.blank?
        @response = Response.new
        @path = questionnaire_responses_path(questionnaire_id: @questionnaire.id)
      else
        @path = questionnaire_response_path(questionnaire_id: @questionnaire.id, id: @response)
      end
    end
end
