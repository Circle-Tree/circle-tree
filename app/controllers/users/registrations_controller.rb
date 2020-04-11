# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update_password, :update_profile]
  before_action :confirm_definitive_registration, only: [:edit_profile, :update_profile, :destroy]
  # prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
  prepend_before_action :authenticate_scope!, only: [:edit_profile, :edit_password, :update_profile, :update_password, :destroy]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

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
    puts '1'
    if resource_updated
      puts '2'
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      puts '3'
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      puts '4'
      flash[:success] = 'プロフィールが変更されました'
      redirect_to users_edit_profile_url
      # respond_with resource, location: after_update_path_for(resource)
    else
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
    puts '0'
    if resource_updated
      puts '1'
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      puts '2'
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      user = current_user
      puts '3'
      user.toggle!(:definitive_registration) unless user.definitive_registration
      puts '4'
      flash[:success] = 'パスワードが変更されました'
      redirect_to users_edit_password_url
      # respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :edit_password
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :definitive_registration, :gender, :grade, :furigana, :agreement])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :definitive_registration, :gender, :grade, :furigana])
  end



  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
