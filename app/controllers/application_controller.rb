# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # include Pundit
  protect_from_forgery with: :exception

  # before_action :configure_permitted_parameters, if: :devise_controller?

  include ApplicationHelper

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end
  include ErrorHandlers # unless Rails.env.development?

  private

    # 幹事のみアクセス可能
    def only_executives_can_access
      return if current_user_group == @group

      # flash[:danger] = '幹事しかアクセスできません'
      raise Forbidden
    end

    # 所属していないグループにはアクセスできない
    def cannot_access_to_other_groups
      return if @group.my_group?(current_user)

      # flash[:danger] = '所属していないグループにはアクセスできません'
      raise Forbidden
    end

    # 現在のユーザーが幹事であるグループをセットする
    # def set_group_for_current_executive
    #   @current_executive_group = Group.my_own_group(current_user)
    # end

    def set_group
      @group = Group.find(params[:group_id])
    end

    def confirm_definitive_registration
      return if current_user.definitive_registration

      flash_and_redirect(key: :danger, message: 'アカウントは一括登録後の状態ですので、パスワードを変更するようにしてください。',
                         redirect_url: users_edit_password_url)
    end

    def other_user_cannot_access
      user = User.find(params[:user_id])
      return if me?(user)

      flash[:danger] = 'アクセス権限がありません'
      raise Forbidden
    end

    def non_admin_user_cannot_access
      return if current_user.admin?

      flash[:danger] = '不正な操作です'
      raise Forbidden
    end

    # ログイン後のリダイレクト先
    def after_sign_in_path_for(resource_or_scope)
      if current_user.admin?
        admin_homes_index_path
      else
        home_path
      end
    end

    # ログアウト後のリダイレクト先
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

    def flash_and_redirect(key: :primary, message:, redirect_url:)
      flash[key] = message
      redirect_to redirect_url
    end

    def flash_and_render(key: :primary, message:, action:)
      flash.now[key] = message
      render action
    end
end
