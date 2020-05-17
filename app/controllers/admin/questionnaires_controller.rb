# frozen_string_literal: true

class Admin::QuestionnairesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :non_admin_user_cannot_access

  def index
    all_questionnaires = Questionnaire.all
    @admin_questionnaires = current_user.questionnaires
    @non_admin_questionnaires = all_questionnaires - @admin_questionnaires
  end

  def new
    @questionnaire = Questionnaire.new
  end

  def create
    @questionnaire = Questionnaire.new(questionnaires_params)
    if @questionnaire.save
      flash_and_redirect(key: :success, message: 'アンケート作成！', redirect_url: admin_questionnaires_url)
    else
      render 'new'
    end
  end

  def edit
    @questionnaire = Questionnaire.find(params[:id])
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    if @questionnaire.update(questionnaires_params)
      flash_and_redirect(key: :success, message: 'アンケート変更！', redirect_url: admin_questionnaires_url)
    else
      render 'edit'
    end
  end

  private

    def questionnaires_params
      params.require(:questionnaire).permit(:title, :content, :user_id)
    end
end
