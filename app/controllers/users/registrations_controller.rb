# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: %i[update_password update_profile]
  before_action :confirm_definitive_registration, only: %i[edit_profile update_profile destroy]
  # prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
  prepend_before_action :authenticate_scope!, only: %i[edit_profile edit_password update_profile update_password destroy]

  # GET /resource/sign_up
  def new
    @group = Group.find_by(group_number: params[:original_group_id])
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        join_circle
        SuccessSlackNotification.registration_notify
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        join_circle
        SuccessSlackNotification.registration_notify
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit_profile
    render :edit_profile
  end

  def edit_password
    render :edit_password
  end

  # PUT /resource
  def update_profile
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource.furigana.present? && resource.grade.present? && resource.is_gender_boolean?
      if resource_updated
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
        flash[:success] = 'プロフィールが変更されました'
        redirect_to users_edit_profile_url
        # respond_with resource, location: after_update_path_for(resource)
      else
        clean_up_passwords resource
        set_minimum_password_length
        render :edit_profile
      end
    else
      resource.errors.add(:base, '入力内容に不備があります。')
      resource.errors.delete(:current_password)
      clean_up_passwords resource
      set_minimum_password_length
      render :edit_profile
    end
  end

  def update_password
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      user = current_user
      user.toggle!(:definitive_registration) unless user.definitive_registration
      flash[:success] = 'パスワードが変更されました'
      redirect_to users_edit_password_url
      # respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :edit_password
    end
  end

  def completed; end

  # DELETE /resource
  def destroy
    resource.leave
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[name definitive_registration gender grade furigana agreement])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[name definitive_registration gender grade furigana])
    end

    # The path used after sign up.
    def after_sign_up_path_for(_resource)
      users_completed_path
      # new_user_session_path
    end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(_resource)
      users_completed_path
      # new_user_session_path
    end

    def join_circle
      GroupUser.create!(user_id: resource.id, group_id: params[:group_id].to_i, role: GroupUser.roles[:general]) if params[:group_id]
    rescue StandardError => e
      ErrorUtility.log_and_notify(e)
    end
end
