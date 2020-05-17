# frozen_string_literal: true

class Admin::ChoosesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :non_admin_user_cannot_access

  def index
    @choose = Choose.new
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @chooses = @questionnaire.chooses.includes(:choice)
    @unselected_choices = Choice.all - @questionnaire.choices
  end

  def create
    @choose = Choose.new(chooses_params)
    if @choose.save
      flash_and_redirect(key: :success, message: '選択肢追加！', redirect_url: admin_questionnaire_chooses_url(questionnaire_id: @choose.questionnaire.id))
    else
      render 'index'
    end
  end

  def destroy
    questionnaire = Questionnaire.find(params[:questionnaire_id])
    choose = Choose.find(params[:id])
    if choose.destroy
      flash_and_redirect(key: :success, message: '選択肢を削除しました', redirect_url: admin_questionnaire_chooses_path(questionnaire_id: questionnaire.id))
    else
      flash_and_render(key: :danger, message: 'エラーにより削除できませんでした', action: 'index')
    end
  end

  def chooses_params
    params.require(:choose).permit(:questionnaire_id, :choice_id)
  end
end
