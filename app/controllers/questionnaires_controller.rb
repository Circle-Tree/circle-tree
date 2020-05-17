# frozen_string_literal: true

class QuestionnairesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration

  def index
    @questionnaire = Questionnaire.new
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

  private

    def questionnaires_params
      params.require(:questionnaire).permit(:title, :content, :user_id)
    end
end
