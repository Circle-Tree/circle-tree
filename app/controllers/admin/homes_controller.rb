# frozen_string_literal: true

class Admin::HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :non_admin_user_cannot_access
  def index
  end

  private

    def non_admin_user_cannot_access
      return if current_user.admin?

      flash[:danger] = '不正な操作です'
      raise Forbidden
    end
end
