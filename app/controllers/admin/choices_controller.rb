# frozen_string_literal: true

class Admin::ChoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :non_admin_user_cannot_access

  def index
    @choices = Choice.all
  end

  def new
    @choice = Choice.new
  end

  def create
    @choice = Choice.new(choices_params)
    if @choice.save
      flash_and_redirect(key: :success, message: '選択肢作成！', redirect_url: admin_choices_url)
    else
      render 'new'
    end
  end

  def edit
    @choice = Choice.find(params[:id])
  end

  def update
    @choice = Choice.find(params[:id])
    if @choice.update(choices_params)
      flash_and_redirect(key: :success, message: '選択肢変更！', redirect_url: admin_choices_url)
    else
      render 'edit'
    end
  end

  def destroy
    choice = Choice.find(params[:id])
    if choice.destroy
      flash_and_redirect(key: :success, message: '選択肢を削除しました', redirect_url: admin_choices_url)
    else
      flash_and_render(key: :danger, message: 'エラーにより削除できませんでした', action: 'index')
    end
  end

  private

    def choices_params
      params.require(:choice).permit(:content)
    end
end
