# frozen_string_literal: true

class Admin::HomesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_definitive_registration
  before_action :non_admin_user_cannot_access
  def index
  end
end
